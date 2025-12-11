import mongoose from 'mongoose';

const UserSchema = new mongoose.Schema(
  {
    email: { type: String, required: true, unique: true, index: true },
    passwordHash: { type: String, required: true },
    phoneNumberE164: { type: String, default: null },
    goalFinalGrade: { type: Number, default: 90 },
  },
  { timestamps: true }
);

export const User = mongoose.model('User', UserSchema);
