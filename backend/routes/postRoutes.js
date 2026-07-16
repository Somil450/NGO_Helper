const express = require('express');
const router = express.Router();
const {
  getPosts,
  getSupplierPosts,
  getNgoClaims,
  getPostById,
  createPost,
  updatePostStatus,
  claimPost,
  manageClaim,
} = require('../controllers/postController');
const { protect } = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');

// Order matters: specific paths before :id
router.get('/supplier', protect, getSupplierPosts);
router.get('/ngo/my-claims', protect, getNgoClaims);

router.route('/')
  .get(protect, getPosts)
  .post(protect, upload.single('image'), createPost);

router.get('/:id', protect, getPostById);
router.put('/:id/status', protect, updatePostStatus);
router.post('/:id/claim', protect, claimPost);
router.put('/:id/claim/manage', protect, manageClaim);

module.exports = router;
