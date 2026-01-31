# Gemini API Setup Guide

## Quick Setup

1. **Get Your Gemini API Key**
   - Visit: https://makersuite.google.com/app/apikey
   - Sign in with your Google account
   - Click "Create API Key"
   - Copy the key

2. **Add to .env File**
   - Open `.env` in project root
   - Replace `your_gemini_api_key_here` with your actual key:
   ```
   GEMINI_API_KEY=AIzaSy...your_actual_key_here
   ```

3. **Test the Integration**
   - Run the app
   - Navigate to Marketplace → Fertilizers
   - Upload a fertilizer bill photo
   - Wait for AI analysis (2-5 seconds)
   - View real-time cheaper alternatives

## Troubleshooting

### "Gemini API key not configured" Error
- Check `.env` file exists
- Verify key is correct (starts with `AIzaSy`)
- Restart the app after adding key

### No Results / Demo Data Showing
- Check console for error messages
- Verify internet connection
- Check API key is valid
- Review API quota limits

### API Costs
- Gemini API pricing: https://ai.google.dev/pricing
- Free tier: 60 requests per minute
- Consider caching responses to reduce calls

## Expected Behavior

✅ **With Valid API Key:**
- Real-time analysis from Krishidnya AI
- Government-subsidized brand recommendations
- Accurate pricing from current market
- Location-specific availability

❌ **Without API Key / On Error:**
- Falls back to demo data
- Shows "⚠️ Falling back to demo data" in console
- Still functional but not personalized
