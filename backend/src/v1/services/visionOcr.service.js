// Optional OCR integration using Google Vision API.
// Enable by setting GOOGLE_VISION_API_KEY.

export async function ocrWithGoogleVisionBase64(imageBase64) {
  const key = process.env.GOOGLE_VISION_API_KEY;
  if (!key) {
    const err = new Error('OCR not configured (missing GOOGLE_VISION_API_KEY)');
    err.statusCode = 400;
    err.code = 'OCR_NOT_CONFIGURED';
    throw err;
  }

  const url = `https://vision.googleapis.com/v1/images:annotate?key=${encodeURIComponent(key)}`;

  const res = await fetch(url, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({
      requests: [
        {
          image: { content: imageBase64 },
          features: [{ type: 'TEXT_DETECTION' }],
        },
      ],
    }),
  });

  const json = await res.json().catch(() => ({}));

  if (!res.ok) {
    const err = new Error('Google Vision OCR failed');
    err.statusCode = 400;
    err.code = 'OCR_FAILED';
    err.details = json;
    throw err;
  }

  const text =
    json?.responses?.[0]?.fullTextAnnotation?.text ??
    json?.responses?.[0]?.textAnnotations?.[0]?.description ??
    '';

  if (!text || typeof text !== 'string') {
    const err = new Error('No text detected in image');
    err.statusCode = 400;
    err.code = 'OCR_NO_TEXT';
    throw err;
  }

  return text;
}
