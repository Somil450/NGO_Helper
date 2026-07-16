const User = require('../models/User');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const nodemailer = require('nodemailer');

const generateToken = (id) =>
  jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: '30d' });

const buildUserResponse = (user, token) => {
  const obj = {
    _id: user._id,
    email: user.email,
    role: user.role,
    supplierDetails: user.supplierDetails ?? null,
    ngoDetails: user.ngoDetails ?? null,
    employeeDetails: user.employeeDetails ?? null,
    donorTier: user.donorTier ?? null,
    yearlyDonationCount: user.yearlyDonationCount ?? 0,
    allTimeDonationCount: user.allTimeDonationCount ?? 0,
    tierLastCalculated: user.tierLastCalculated ?? null,
    notificationsClearedAt: user.notificationsClearedAt ?? null,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
  };
  if (token) obj.token = token;
  return obj;
};

// Setup nodemailer transporter
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

// Helper: generate and save a 6-digit OTP
const saveOtp = async (user) => {
  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  user.otp = otp;
  user.otpExpiry = new Date(Date.now() + 10 * 60 * 1000); // 10 min
  await user.save();
  console.log(`[DEV] Saved OTP for user: ${otp}`);
  return otp;
};

// Send real email using Nodemailer
const sendEmail = async (email, otp) => {
  if (!process.env.EMAIL_USER || !process.env.EMAIL_PASS) {
    console.log(`[OTP] Code for ${email}: ${otp} (Email not configured in .env)`);
    return;
  }
  
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: 'Your ManavSeva Verification Code',
    text: `Your 6-digit verification code is: ${otp}\n\nThis code is valid for 10 minutes.`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h2 style="color: #059669;">ManavSeva Verification</h2>
        <p>Thank you for joining our mission to ensure no food goes to waste.</p>
        <p>Your verification code is:</p>
        <h1 style="letter-spacing: 5px; color: #064e3b; background: #ecfdf5; padding: 10px; text-align: center; border-radius: 8px;">${otp}</h1>
        <p>This code will expire in 10 minutes.</p>
      </div>
    `
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log(`Real OTP email sent successfully to ${email}`);
  } catch (error) {
    console.error(`Failed to send email to ${email}:`, error);
  }
};

// ─── POST /api/auth/check-email ─────────────────────────────────────────────
const checkEmail = async (req, res) => {
  try {
    const { email } = req.body;
    const exists = await User.findOne({ email: email?.toLowerCase() });
    if (exists) {
      return res.status(409).json({ message: 'Email already in use. Please log in.' });
    }
    return res.status(200).json({ message: 'Email is available.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

const registrationOtps = new Map();

// ─── POST /api/auth/send-otp ────────────────────────────────────────────────
const sendOtp = async (req, res) => {
  try {
    const { email } = req.body;
    // Create a temp user doc or find existing
    let user = await User.findOne({ email: email?.toLowerCase() });
    if (!user) {
      // Store OTP even before registration by creating a minimal placeholder
      // (the real flow: check-email → send-otp → register with OTP)
      const otp = Math.floor(100000 + Math.random() * 900000).toString();
      console.log(`[DEV] Generated new OTP for ${email}: ${otp}`);
      registrationOtps.set(email.toLowerCase(), { otp, expiresAt: Date.now() + 10 * 60 * 1000 });
      await sendEmail(email, otp);
      return res.status(200).json({ message: 'OTP sent successfully.' });
    }
    const otp = await saveOtp(user);
    await sendEmail(email, otp);
    return res.status(200).json({ message: 'OTP sent successfully.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ─── POST /api/auth/verify-otp ──────────────────────────────────────────────
const verifyOtp = async (req, res) => {
  try {
    const { email, otp } = req.body;
    const user = await User.findOne({ email: email?.toLowerCase() });
    if (!user) {
      // 404 triggers client-side "proceed to reset" (as seen in bundle)
      return res.status(404).json({ message: 'User not found.' });
    }
    if (!user.otp || user.otp !== otp || new Date() > user.otpExpiry) {
      return res.status(400).json({ message: 'Invalid or expired OTP.' });
    }
    return res.status(200).json({ message: 'OTP verified.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ─── POST /api/auth/forgot-password-otp ────────────────────────────────────
const forgotPasswordOtp = async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email: email?.toLowerCase() });
    if (!user) return res.status(404).json({ message: 'No account found with this email.' });
    const otp = await saveOtp(user);
    await sendEmail(email, otp);
    return res.status(200).json({ message: `Security code sent to ${email}` });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ─── POST /api/auth/reset-password ──────────────────────────────────────────
const resetPassword = async (req, res) => {
  try {
    const { email, otp, newPassword } = req.body;
    const user = await User.findOne({ email: email?.toLowerCase() });
    if (!user) return res.status(404).json({ message: 'User not found.' });
    if (!user.otp || user.otp !== otp || new Date() > user.otpExpiry) {
      return res.status(400).json({ message: 'Invalid or expired OTP.' });
    }
    user.password = newPassword; // pre-save hook will hash it
    user.otp = undefined;
    user.otpExpiry = undefined;
    await user.save();
    return res.status(200).json({ message: 'Password reset successfully.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ─── POST /api/auth/register ────────────────────────────────────────────────
const registerUser = async (req, res) => {
  try {
    const { email, password, role, otp, details } = req.body;
    if (!email || !password || !role) {
      return res.status(400).json({ message: 'Email, password, and role are required.' });
    }

    const exists = await User.findOne({ email: email.toLowerCase() });
    if (exists) {
      return res.status(409).json({ message: 'User already exists.' });
    }
    
    // Verify OTP for registration
    const pending = registrationOtps.get(email.toLowerCase());
    if (!pending || pending.otp !== otp || Date.now() > pending.expiresAt) {
      return res.status(400).json({ message: 'Invalid or expired OTP.' });
    }

    const normalizedRole = role.toUpperCase() === 'NGO' ? 'NGO' : role.charAt(0).toUpperCase() + role.slice(1).toLowerCase();
    const userData = { email: email.toLowerCase(), password, role: normalizedRole };

    if (normalizedRole === 'Supplier' && details) {
      userData.supplierDetails = { ...details };
    } else if (normalizedRole === 'NGO' && details) {
      userData.ngoDetails = { ...details };
    } else if (normalizedRole === 'Employee' && details) {
      userData.employeeDetails = { ...details };
    }

    const user = await User.create(userData);
    registrationOtps.delete(email.toLowerCase()); // Clear OTP after success
    
    const token = generateToken(user._id);
    return res.status(201).json(buildUserResponse(user, token));
  } catch (err) {
    console.error('[Register]', err);
    res.status(500).json({ message: err.message });
  }
};

// ─── POST /api/auth/login ────────────────────────────────────────────────────
const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required.' });
    }
    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user || !(await user.matchPassword(password))) {
      return res.status(401).json({ message: 'Invalid email or password.' });
    }
    const token = generateToken(user._id);
    return res.status(200).json(buildUserResponse(user, token));
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Receives a Google access token, fetches user info, and logs in / registers
const googleAuth = async (req, res) => {
  try {
    const { token: googleToken, role, isLogin } = req.body;
    const googleRes = await fetch(`https://www.googleapis.com/oauth2/v3/userinfo`, {
      headers: { Authorization: `Bearer ${googleToken}` },
    });
    const profile = await googleRes.json();
    if (!profile.email) return res.status(400).json({ message: 'Google auth failed.' });

    let user = await User.findOne({ email: profile.email.toLowerCase() });
    
    if (isLogin) {
      if (!user) {
        return res.status(404).json({ message: 'User not found. Please create an account first.' });
      }
    } else {
      if (user) {
        return res.status(409).json({ message: 'User already exists. Please sign in instead.' });
      }
      if (!role) return res.status(400).json({ message: 'Role is required for new registrations.' });
      const normalizedRole = role.toUpperCase() === 'NGO' ? 'NGO' : role.charAt(0).toUpperCase() + role.slice(1).toLowerCase();
      user = await User.create({
        email: profile.email.toLowerCase(),
        password: crypto.randomBytes(20).toString('hex'),
        role: normalizedRole,
        ...(normalizedRole === 'NGO' ? { ngoDetails: { name: profile.name } } : {}),
        ...(normalizedRole === 'Supplier' ? { supplierDetails: { legalName: profile.name } } : {}),
      });
    }

    const jwtToken = generateToken(user._id);
    return res.status(200).json(buildUserResponse(user, jwtToken));
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ─── GET /api/auth/me ────────────────────────────────────────────────────────
const getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('-password');
    if (!user) return res.status(404).json({ message: 'User not found.' });
    return res.status(200).json(buildUserResponse(user));
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ─── PUT /api/auth/me ────────────────────────────────────────────────────────
const updateMe = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user) return res.status(404).json({ message: 'User not found.' });

    const { details, password } = req.body;
    if (!details && !password) return res.status(400).json({ message: 'No updates provided.' });

    if (password) {
      user.password = password;
    }

    if (details) {

    if (user.role === 'Supplier') {
      const existing = user.supplierDetails?.toObject?.() || user.supplierDetails || {};
      user.supplierDetails = { ...existing, ...details };
      user.markModified('supplierDetails');
    } else if (user.role === 'NGO') {
      const existing = user.ngoDetails?.toObject?.() || user.ngoDetails || {};
      user.ngoDetails = { ...existing, ...details };
      user.markModified('ngoDetails');
    } else if (user.role === 'Employee') {
      const existing = user.employeeDetails?.toObject?.() || user.employeeDetails || {};
      user.employeeDetails = { ...existing, ...details };
      user.markModified('employeeDetails');
    }
    }

    await user.save();
    return res.status(200).json(buildUserResponse(user));
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

module.exports = {
  checkEmail, sendOtp, verifyOtp, forgotPasswordOtp,
  resetPassword, registerUser, loginUser, googleAuth, getMe, updateMe,
};
