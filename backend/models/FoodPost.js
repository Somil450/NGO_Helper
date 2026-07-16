const mongoose = require('mongoose');

const dayScheduleSchema = new mongoose.Schema(
  {
    day: { type: String, required: true },
    isActive: { type: Boolean, default: false },
    postTime: { type: String, default: '09:00' },
    deadlineTime: { type: String, default: '12:00' },
  },
  { _id: false }
);

const claimSubSchema = new mongoose.Schema(
  {
    ngoId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    ngoName: String,
    ngoPhone: String,
    notes: String,
    status: {
      type: String,
      enum: ['Pending', 'Approved', 'Rejected', 'Completed'],
      default: 'Pending',
    },
    isEmployeeReached: { type: Boolean, default: false },
    assignedEmployeeId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null },
  },
  { timestamps: true }
);

const foodPostSchema = new mongoose.Schema(
  {
    supplierId: {
      type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true,
    },
    type: {
      type: String, enum: ['OneTime', 'Scheduled'], default: 'OneTime',
    },

    // Food details
    itemName: String,
    category: { type: String, required: true },
    weight: { type: Number, required: true },
    packaging: {
      type: mongoose.Schema.Types.Mixed, // accepts true/false or 'Packaged'/'Unpackaged'
      default: false,
    },
    shelfLife: String,

    // Location
    pickupAddress: { type: String, required: true },
    city: { type: String, required: true },
    district: { type: String, required: true },
    state: { type: String, required: true },
    lat: { type: Number, default: null },
    lng: { type: Number, default: null },

    // Timing
    pickupDate: Date,

    // Contact
    contactName: { type: String, required: true },
    contactPhone: { type: String, required: true },
    specialInstructions: String,

    // Media
    image: { type: String, default: '' },

    // Status
    status: {
      type: String,
      enum: ['Active', 'Claimed', 'Expired', 'Completed'],
      default: 'Active',
    },

    // Scheduled
    scheduledDays: [dayScheduleSchema],

    // Claims embedded
    claims: [claimSubSchema],
  },
  { timestamps: true }
);

module.exports = mongoose.model('FoodPost', foodPostSchema);
