const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const savedAddressSchema = new mongoose.Schema(
  {
    label: String,
    address: String,
    city: String,
    district: String,
    state: String,
    lat: Number,
    lng: Number,
    isDefault: { type: Boolean, default: false },
  },
  { _id: true }
);

const userSchema = new mongoose.Schema(
  {
    email: {
      type: String, required: true, unique: true, lowercase: true, trim: true,
    },
    password: { type: String, required: true },
    role: {
      type: String,
      enum: ['Supplier', 'NGO', 'Employee'],
      required: true,
    },

    // ── Supplier Details ──────────────────────────────────────────────────────
    supplierDetails: {
      businessType: String,
      legalName: String,
      entityName: String,
      address: String,
      city: String,
      district: String,
      state: String,
      lat: { type: Number, default: null },
      lng: { type: Number, default: null },
      mobile: String,
      website: String,
      savedAddresses: { type: [savedAddressSchema], default: [] },
      totalWeightDonated: { type: Number, default: 0 },
      totalMealsDonated: { type: Number, default: 0 },
      totalPosts: { type: Number, default: 0 },
    },

    // ── NGO Details ───────────────────────────────────────────────────────────
    ngoDetails: {
      name: String,
      mission: String,
      address: String,
      city: String,
      district: String,
      state: String,
      lat: { type: Number, default: null },
      lng: { type: Number, default: null },
      mobile: String,
      website: String,
      acceptedDonations: { type: [String], default: [] },
    },

    // ── Employee Details ──────────────────────────────────────────────────────
    employeeDetails: {
      name: String,
      mobile: String,
      ngoId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
      isActive: { type: Boolean, default: true },
    },

    // ── Meta ──────────────────────────────────────────────────────────────────
    donorTier: { type: String, default: null },
    yearlyDonationCount: { type: Number, default: 0 },
    allTimeDonationCount: { type: Number, default: 0 },
    tierLastCalculated: { type: Date, default: null },
    notificationsClearedAt: { type: Date, default: null },

    // OTP for email verification / password reset
    otp: String,
    otpExpiry: Date,
  },
  { timestamps: true }
);

// ── Mongoose 9 compatible pre-save hook (no `next` parameter) ─────────────────
userSchema.pre('save', async function () {
  if (!this.isModified('password')) return;
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

userSchema.methods.matchPassword = async function (entered) {
  return bcrypt.compare(entered, this.password);
};

module.exports = mongoose.model('User', userSchema);
