const FoodPost = require('../models/FoodPost');
const User = require('../models/User');

// Helper: get packaging value as bool or string consistently
const normalizePackaging = (val) => {
  if (val === true || val === 'true' || val === 'Packaged') return true;
  return false;
};

// ─── GET /api/posts  ── All active OneTime posts (NGO feed) ──────────────────
const getPosts = async (req, res) => {
  try {
    const posts = await FoodPost.find({ type: 'OneTime', status: 'Active' })
      .populate('supplierId', 'supplierDetails donorTier')
      .sort({ createdAt: -1 });

    const ngoUser = await User.findById(req.user._id);
    const ngoLat = ngoUser?.ngoDetails?.lat;
    const ngoLng = ngoUser?.ngoDetails?.lng;

    const result = posts.map((p) => {
      const obj = p.toObject();

      // Add hasClaimed flag
      const alreadyClaimed = p.claims.some(
        (c) => c.ngoId?.toString() === req.user._id.toString() && c.status !== 'Rejected'
      );
      obj.hasClaimed = alreadyClaimed;

      // Calculate approximate distance (km) if coordinates available
      if (ngoLat && ngoLng && p.lat && p.lng) {
        obj.distance = getDistanceKm(ngoLat, ngoLng, p.lat, p.lng);
      }

      return obj;
    });

    return res.json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ─── GET /api/posts/supplier  ── All posts by this supplier ──────────────────
const getSupplierPosts = async (req, res) => {
  try {
    const posts = await FoodPost.find({ supplierId: req.user._id })
      .sort({ createdAt: -1 });
    return res.json(posts);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ─── GET /api/posts/ngo/my-claims  ── All claims by this NGO ─────────────────
const getNgoClaims = async (req, res) => {
  try {
    // Find all posts where this NGO has a claim
    const posts = await FoodPost.find({ 'claims.ngoId': req.user._id })
      .populate('supplierId', 'supplierDetails donorTier');

    const result = [];
    for (const post of posts) {
      const claim = post.claims.find(
        (c) => c.ngoId?.toString() === req.user._id.toString()
      );
      if (!claim) continue;

      result.push({
        id: post._id,
        claimId: claim._id,
        supplier: post.supplierId?.supplierDetails?.legalName || '',
        supplierTier: post.supplierId?.donorTier || null,
        itemName: post.itemName || post.category || '',
        category: post.category || '',
        weight: post.weight || 0,
        status: claim.status,
        date: post.pickupDate
          ? new Date(post.pickupDate).toLocaleDateString('en-IN', {
              weekday: 'long', month: 'short', day: 'numeric',
            })
          : '',
        address: post.pickupAddress || '',
        pickupLat: post.lat || null,
        pickupLng: post.lng || null,
        ngoLiveLat: null,
        ngoLiveLng: null,
        ngoRegistrationLat: null,
        ngoRegistrationLng: null,
        assignedEmployeeId: claim.assignedEmployeeId || null,
        isEmployeeReached: claim.isEmployeeReached || false,
        image: post.image || '',
      });
    }

    return res.json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ─── GET /api/posts/:id  ── Single post with embedded claims ─────────────────
const getPostById = async (req, res) => {
  try {
    const post = await FoodPost.findById(req.params.id)
      .populate('supplierId', 'supplierDetails donorTier');

    if (!post) return res.status(404).json({ message: 'Post not found.' });

    const obj = post.toObject();
    const hasClaimed = post.claims.some(
      (c) => c.ngoId?.toString() === req.user._id.toString() && c.status !== 'Rejected'
    );
    obj.hasClaimed = hasClaimed;

    return res.json(obj);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ─── POST /api/posts  ── Create a post (OneTime or Scheduled) ────────────────
const createPost = async (req, res) => {
  try {
    const {
      type, itemName, category, weight, packaging,
      shelfLife, pickupAddress, city, district, state,
      lat, lng,
      pickupDate, contactName, contactPhone, specialInstructions,
      scheduledDays,
    } = req.body;

    if (!category || !weight || !pickupAddress || !city || !state || !contactName || !contactPhone) {
      return res.status(400).json({ message: 'Missing required fields.' });
    }

    const postData = {
      supplierId: req.user._id,
      type: type || 'OneTime',
      itemName: itemName || category,
      category,
      weight: parseFloat(weight),
      packaging: normalizePackaging(packaging),
      shelfLife: shelfLife || '',
      pickupAddress,
      city,
      district: district || city,
      state,
      lat: lat ? parseFloat(lat) : null,
      lng: lng ? parseFloat(lng) : null,
      contactName,
      contactPhone,
      specialInstructions: specialInstructions || '',
      image: req.file ? `/uploads/${req.file.filename}` : '',
    };

    if (postData.type === 'OneTime') {
      postData.pickupDate = pickupDate ? new Date(pickupDate) : new Date();
    } else if (postData.type === 'Scheduled') {
      postData.scheduledDays = scheduledDays
        ? (typeof scheduledDays === 'string' ? JSON.parse(scheduledDays) : scheduledDays)
        : [];
    }

    const post = await FoodPost.create(postData);

    // Update supplier stats
    await User.findByIdAndUpdate(req.user._id, {
      $inc: { 'supplierDetails.totalPosts': 1 },
    });

    return res.status(201).json(post);
  } catch (err) {
    console.error('[CreatePost]', err);
    res.status(500).json({ message: err.message });
  }
};

// ─── PUT /api/posts/:id/status  ── Supplier updates a post status ─────────────
const updatePostStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const post = await FoodPost.findById(req.params.id);
    if (!post) return res.status(404).json({ message: 'Post not found.' });
    if (post.supplierId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized.' });
    }
    post.status = status;
    await post.save();
    return res.json(post);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ─── POST /api/posts/:id/claim  ── NGO claims a post ─────────────────────────
const claimPost = async (req, res) => {
  try {
    const post = await FoodPost.findById(req.params.id);
    if (!post) return res.status(404).json({ message: 'Post not found.' });
    if (post.status !== 'Active') {
      return res.status(400).json({ message: 'This post is no longer available.' });
    }

    // Prevent duplicate pending claim from same NGO
    const alreadyClaimed = post.claims.some(
      (c) => c.ngoId?.toString() === req.user._id.toString() && c.status === 'Pending'
    );
    if (alreadyClaimed) {
      return res.status(400).json({ message: 'You have already requested this item.' });
    }

    const ngoUser = await User.findById(req.user._id);
    post.claims.push({
      ngoId: req.user._id,
      ngoName: ngoUser?.ngoDetails?.name || ngoUser?.ngoDetails?.ngoName || '',
      ngoPhone: ngoUser?.ngoDetails?.mobile || ngoUser?.ngoDetails?.mobileNumber || '',
      notes: req.body.notes || '',
    });
    await post.save();

    return res.status(200).json({ message: 'Success' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ─── PUT /api/posts/:id/claim/manage  ── Supplier approves/rejects ────────────
const manageClaim = async (req, res) => {
  try {
    const { claimId, status } = req.body;

    const post = await FoodPost.findById(req.params.id);
    if (!post) return res.status(404).json({ message: 'Post not found.' });

    const claim = post.claims.id(claimId);
    if (!claim) return res.status(404).json({ message: 'Claim not found.' });

    if (post.supplierId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized.' });
    }

    claim.status = status;

    if (status === 'Approved') {
      post.status = 'Claimed';
      // Reject all other pending claims
      post.claims.forEach((c) => {
        if (c._id.toString() !== claimId && c.status === 'Pending') {
          c.status = 'Rejected';
        }
      });

      // Update supplier donation stats
      const weight = post.weight || 0;
      const meals = Math.floor((weight * 1000) / 400);
      await User.findByIdAndUpdate(post.supplierId, {
        $inc: {
          'supplierDetails.totalWeightDonated': weight,
          'supplierDetails.totalMealsDonated': meals,
          'allTimeDonationCount': 1,
          'yearlyDonationCount': 1,
        },
      });
    }

    await post.save();
    return res.json(claim);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ─── Haversine distance ───────────────────────────────────────────────────────
function getDistanceKm(lat1, lng1, lat2, lng2) {
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}
function toRad(deg) { return (deg * Math.PI) / 180; }

module.exports = {
  getPosts, getSupplierPosts, getNgoClaims, getPostById,
  createPost, updatePostStatus, claimPost, manageClaim,
};
