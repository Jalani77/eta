import mongoose from 'mongoose';

const CategorySchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    weight: { type: Number, required: true },
  },
  { _id: false }
);

const EventSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    dueAt: { type: Date, required: true },
    category: { type: String, default: null },
    pointsPossible: { type: Number, default: null },
  },
  { _id: false }
);

const GradeSchema = new mongoose.Schema(
  {
    eventTitle: { type: String, required: true },
    category: { type: String, required: true },
    scoreEarned: { type: Number, required: true },
    scorePossible: { type: Number, required: true },
    gradedAt: { type: Date, default: () => new Date() },
  },
  { _id: false }
);

const ClassSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    className: { type: String, required: true },
    categories: { type: [CategorySchema], default: [] },
    events: { type: [EventSchema], default: [] },
    grades: { type: [GradeSchema], default: [] },

    assumedRemainingAverage: { type: Number, default: 85 },
  },
  { timestamps: true }
);

export const ClassModel = mongoose.model('Class', ClassSchema);
