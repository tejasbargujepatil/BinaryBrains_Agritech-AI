from app.agents.base_agent import BaseAgent
from app.knowledge.crop_knowledge_base import get_crop_data
from typing import List, Dict
import math

class PriceAnalysisAgent(BaseAgent):
    """Rule-based Agent for analyzing market prices and providing selling recommendations"""
    
    def __init__(self):
        super().__init__('price_analysis_agent')
    
    def execute(self, crop_name: str, markets: list, user_location: dict) -> dict:
        """
        Analyze market prices and provide selling recommendations using rule-based logic
        
        Args:
            crop_name: Name of crop to analyze
            markets: List of market data [{name, price, location: {lat, lon}}]
            user_location: {latitude, longitude, location_name}
        
        Returns:
            Market analysis with recommendations
        """
        crop_data = get_crop_data(crop_name.lower())
        
        if not crop_data:
            return {
                "error": f"Crop '{crop_name}' not found in knowledge base",
                "supported_crops": ["sugarcane", "cotton", "rice", "jowar", "wheat", "tur", "soybean", "groundnut", "sunflower", "gram"]
            }
        
        # Get market calendar data
        market_calendar = crop_data.get("market_calendar", {})
        avg_price = market_calendar.get("avg_price_per_quintal", 
                                        market_calendar.get("avg_price_per_ton", 3000))
        
        # Calculate distances and analyze markets
        market_analysis = []
        for market in markets:
            distance = self._calculate_distance(
                user_location['latitude'],
                user_location['longitude'],
                market['location']['latitude'],
                market['location']['longitude']
            )
            
            # Calculate transport cost (₹5 per km per quintal as baseline)
            transport_cost_per_quintal = distance * 5
            
            # Net price after transport
            net_price = market['price'] - transport_cost_per_quintal
            
            # Price comparison to average
            price_vs_avg = ((market['price'] - avg_price) / avg_price) * 100
            
            # Determine price level
            if market['price'] > avg_price * 1.1:
                price_level = "Excellent"
            elif market['price'] > avg_price:
                price_level = "Good"
            elif market['price'] > avg_price * 0.9:
                price_level = "Average"
            else:
                price_level = "Below Average"
            
            market_analysis.append({
                "market_name": market['name'],
                "current_price": market['price'],
                "distance_km": round(distance, 1),
                "transport_cost": int(transport_cost_per_quintal),
                "net_price": int(net_price),
                "price_level": price_level,
                "price_vs_average": round(price_vs_avg, 1)
            })
        
        # Sort by net price (descending)
        market_analysis.sort(key=lambda x: x['net_price'], reverse=True)
        
        # Get top 5 markets
        top_markets = market_analysis[:5]
        
        # Determine best market
        if top_markets:
            best_market = top_markets[0]
            
            # Calculate profit potential
            profit_vs_avg = best_market['net_price'] - avg_price
            
            # Build recommendation
            if best_market['net_price'] > avg_price * 1.05:
                strategy = f"Sell immediately at {best_market['market_name']}"
                reason = f"Net price ₹{best_market['net_price']} is {round(((best_market['net_price']-avg_price)/avg_price)*100, 1)}% above market average"
            elif best_market['distance_km'] > 50:
                strategy = f"Consider local markets first"
                reason = f"Transport cost to {best_market['market_name']} is high (₹{best_market['transport_cost']}/quintal)"
            else:
                strategy = f"Sell at {best_market['market_name']}"
                reason = f"Best net price after transport: ₹{best_market['net_price']}/quintal"
            
            recommendation = {
                "recommended_market": best_market['market_name'],
                "expected_price": best_market['net_price'],
                "strategy": strategy,
                "reasoning": reason,
                "profit_vs_average": int(profit_vs_avg)
            }
        else:
            recommendation = {
                "recommended_market": "Unknown",
                "expected_price": int(avg_price),
                "strategy": "Wait for market data",
                "reasoning": "Insufficient market information",
                "profit_vs_average": 0
            }
        
        # Price trend analysis (rule-based)
        current_month = __import__('datetime').datetime.now().month
        peak_months = market_calendar.get("peak_demand_months", [])
        
        # Determine trend
        if current_month in peak_months:
            trend = "stable"
            trend_message = "Currently in peak season - prices stable"
        elif (current_month + 1) % 12 in peak_months:
            trend = "rising"
            trend_message = "Peak season approaching next month - prices may rise"
        elif (current_month - 1) % 12 in peak_months:
            trend = "falling"
            trend_message = "Just past peak season - prices declining"
        else:
            trend = "stable"
            trend_message = "Off-season period - prices relatively stable"
        
        # Market insights
        insights = [
            f"Average market price for {crop_name.title()}: ₹{int(avg_price)}/quintal",
            f"Best market offers ₹{top_markets[0]['current_price']}/quintal" if top_markets else "No market data available",
            f"Transport costs range from ₹{min(m['transport_cost'] for m in top_markets)} to ₹{max(m['transport_cost'] for m in top_markets)}" if len(top_markets) > 1 else "",
            trend_message
        ]
        insights = [i for i in insights if i]  # Remove empty strings
        
        # Best practices
        best_practices = [
            "Compare prices across multiple markets before selling",
            "Factor in transport costs when choosing markets",
            "Check market timings - arrive early for better prices",
            "Join FPO or cooperatives for better bargaining power",
            "Use e-NAM platform for transparent price discovery"
        ]
        
        # Alternative selling options
        alternatives = [
            {
                "option": "e-NAM Portal",
                "benefits": "Pan-India price discovery, transparent bidding",
                "requirements": "Online registration, basic digital literacy"
            },
            {
                "option": "Contract Farming",
                "benefits": "Fixed price guarantee, reduced market risk",
                "requirements": "Pre-harvest agreement with buyer"
            },
            {
                "option": "FPO/Cooperative",
                "benefits": "Collective bargaining, bulk selling premiums",
                "requirements": "FPO membership"
            }
        ]
        
        return {
            "top_markets": top_markets,
            "recommendation": recommendation,
            "price_trend": {
                "current_trend": trend,
                "analysis": trend_message,
                "confidence": 75
            },
            "market_insights": insights,
            "best_practices": best_practices,
            "alternative_selling_options": alternatives,
            "average_market_price": int(avg_price),
            "analysis_method": "rule_based_knowledge_base"
        }
    
    def _calculate_distance(self, lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """Calculate distance between two points using Haversine formula"""
        # Earth radius in kilometers
        R = 6371
        
        # Convert to radians
        lat1_rad = math.radians(lat1)
        lat2_rad = math.radians(lat2)
        delta_lat = math.radians(lat2 - lat1)
        delta_lon = math.radians(lon2 - lon1)
        
        # Haversine formula
        a = math.sin(delta_lat/2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(delta_lon/2)**2
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
        distance = R * c
        
        return distance

# Instantiate the agent
price_analysis_agent = PriceAnalysisAgent()
