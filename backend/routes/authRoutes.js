const express = require('express');
const router = express.Router();
const {
  checkEmail, sendOtp, verifyOtp, forgotPasswordOtp,
  resetPassword, registerUser, loginUser, googleAuth, getMe, updateMe,
} = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

// Public routes
router.post('/check-email', checkEmail);
router.post('/send-otp', sendOtp);
router.post('/verify-otp', verifyOtp);
router.post('/forgot-password-otp', forgotPasswordOtp);
router.post('/reset-password', resetPassword);
router.post('/register', registerUser);
router.post('/login', loginUser);
router.post('/google', googleAuth);

// Protected routes
router.get('/me', protect, getMe);
router.put('/me', protect, updateMe);

module.exports = router;
