"""
Crop Knowledge Base for Maharashtra - Top 10 Crops
Contains agricultural rules, schedules, and data for rule-based agent decisions
"""

from datetime import datetime, timedelta
from typing import Dict, List, Optional

# Top 10 Maharashtra crops agricultural knowledge base
CROP_DATABASE = {
    "sugarcane": {
        "marathi_name": "ऊस",
        "scientific_name": "Saccharum officinarum",
        "varieties": ["Co-86032", "Co-0238", "Co-94012", "Co-98014"],
        "duration_months": 12,
        "seasons": ["Year-round (plant Feb-March or Oct-Nov)"],
        
        "soil_requirements": {
            "optimal_ph": {"min": 6.5, "max": 7.5},
            "soil_types": ["Black", "Loamy", "Red"],
            "npk_requirements": {
                "nitrogen": {"min": 200, "max": 300},  # kg/acre
                "phosphorus": {"min": 80, "max": 100},
                "potassium": {"min": 80, "max": 120}
            }
        },
        
        "fertilization_schedule": [
            {
                "stage": "Planting",
                "timing_days": 0,
                "fertilizers": [
                    {"name": "IFFCO DAP", "npk": "18-46-0", "quantity_per_acre": 65, "unit": "kg"},
                    {"name": "Potash", "npk": "0-0-60", "quantity_per_acre": 35, "unit": "kg"}
                ]
            },
            {
                "stage": "45 Days After Planting",
                "timing_days": 45,
                "fertilizers": [
                    {"name": "IFFCO Urea", "npk": "46-0-0", "quantity_per_acre": 85, "unit": "kg"}
                ]
            },
            {
                "stage": "90 Days After Planting",
                "timing_days": 90,
                "fertilizers": [
                    {"name": "IFFCO Urea", "npk": "46-0-0", "quantity_per_acre": 85, "unit": "kg"}
                ]
            }
        ],
        
        "irrigation_schedule": {
            "germination": {"frequency_days": 3, "water_mm": 50},
            "tillering": {"frequency_days": 7, "water_mm": 75},
            "grand_growth": {"frequency_days": 7, "water_mm": 100},
            "maturity": {"frequency_days": 10, "water_mm": 50}
        },
        
        "common_diseases": {
            "red_rot": {
                "symptoms": ["red patches on leaves", "drying of leaves", "rotting of stem"],
                "treatment_chemical": "Carbendazim 50% WP @ 2g/liter",
                "treatment_organic": "Neem oil spray @ 5ml/liter",
                "prevention": ["Use resistant varieties", "Crop rotation", "Remove infected plants"]
            },
            "smut": {
                "symptoms": ["whip-like structure", "black spores", "stunted growth"],
                "treatment_chemical": "Propiconazole @ 1ml/liter",
                "treatment_organic": "Remove infected shoots immediately",
                "prevention": ["Hot water treatment of setts", "Resistant varieties"]
            }
        },
        
        "harvest_indicators": {
            "maturity_days": 360,
            "brix_level": 18,
            "physical_signs": ["Yellowing of lower leaves", "Hardening of cane", "Sweet taste"]
        },
        
        "market_calendar": {
            "peak_demand_months": [11, 12, 1, 2],  # Nov-Feb
            "avg_price_per_ton": 3000,
            "price_variation": {"peak": 3200, "off_season": 2800}
        },
        
        "expected_yield": {"min": 40, "max": 50, "unit": "tons/acre"}
    },
    
    "cotton": {
        "marathi_name": "कापूस",
        "scientific_name": "Gossypium hirsutum",
        "varieties": ["Bt Cotton", "RCH-2", "Ankur-3028", "Tulasi-9"],
        "duration_months": 6,
        "seasons": ["Kharif (June-October)"],
        
        "soil_requirements": {
            "optimal_ph": {"min": 6.0, "max": 8.0},
            "soil_types": ["Black", "Red", "Alluvial"],
            "npk_requirements": {
                "nitrogen": {"min": 100, "max": 150},
                "phosphorus": {"min": 50, "max": 70},
                "potassium": {"min": 40, "max": 60}
            }
        },
        
        "fertilization_schedule": [
            {
                "stage": "Basal Application",
                "timing_days": 0,
                "fertilizers": [
                    {"name": "IFFCO DAP", "npk": "18-46-0", "quantity_per_acre": 40, "unit": "kg"},
                    {"name": "Potash", "npk": "0-0-60", "quantity_per_acre": 20, "unit": "kg"}
                ]
            },
            {
                "stage": "30-35 Days (Square Formation)",
                "timing_days": 32,
                "fertilizers": [
                    {"name": "IFFCO Urea", "npk": "46-0-0", "quantity_per_acre": 45, "unit": "kg"}
                ]
            },
            {
                "stage": "60 Days (Flowering)",
                "timing_days": 60,
                "fertilizers": [
                    {"name": "IFFCO Urea", "npk": "46-0-0", "quantity_per_acre": 35, "unit": "kg"}
                ]
            }
        ],
        
        "irrigation_schedule": {
            "sowing": {"frequency_days": 5, "water_mm": 40},
            "vegetative": {"frequency_days": 10, "water_mm": 50},
            "flowering": {"frequency_days": 7, "water_mm": 60},
            "boll_development": {"frequency_days": 10, "water_mm": 50}
        },
        
        "common_diseases": {
            "bacterial_blight": {
                "symptoms": ["water-soaked lesions", "angular leaf spots", "yellowing"],
                "treatment_chemical": "Streptocycline @ 0.5g/liter + Copper oxychloride @ 2g/liter",
                "treatment_organic": "Bordeaux mixture @ 10g/liter",
                "prevention": ["Use certified seeds", "Avoid overhead irrigation"]
            },
            "pink_bollworm": {
                "symptoms": ["pink caterpillars in bolls", "rosette flowers", "boll damage"],
                "treatment_chemical": "Cypermethrin @ 1ml/liter",
                "treatment_organic": "Pheromone traps, Neem seed kernel extract @ 50g/liter",
                "prevention": ["Early sowing", "Destroy crop residue", "Trap crops"]
            }
        },
        
        "harvest_indicators": {
            "maturity_days": 180,
            "physical_signs": ["Bolls burst open", "Fluffy white cotton", "Brown boll shells"]
        },
        
        "market_calendar": {
            "peak_demand_months": [10, 11, 12],
            "avg_price_per_quintal": 6000,
            "price_variation": {"peak": 6500, "off_season": 5500}
        },
        
        "expected_yield": {"min": 12, "max": 18, "unit": "quintals/acre"}
    },
    
    "rice": {
        "marathi_name": "तांदूळ",
        "scientific_name": "Oryza sativa",
        "varieties": ["Swarna", "IR-64", "MTU-1010", "Indrayani"],
        "duration_months": 4,
        "seasons": ["Kharif (June-November)"],
        
        "soil_requirements": {
            "optimal_ph": {"min": 5.5, "max": 6.5},
            "soil_types": ["Clayey", "Loamy"],
            "npk_requirements": {
                "nitrogen": {"min": 120, "max": 150},
                "phosphorus": {"min": 60, "max": 80},
                "potassium": {"min": 40, "max": 60}
            }
        },
        
        "fertilization_schedule": [
            {
                "stage": "Transplanting",
                "timing_days": 0,
                "fertilizers": [
                    {"name": "IFFCO DAP", "npk": "18-46-0", "quantity_per_acre": 45, "unit": "kg"},
                    {"name": "Potash", "npk": "0-0-60", "quantity_per_acre": 25, "unit": "kg"}
                ]
            },
            {
                "stage": "Tillering (25 Days)",
                "timing_days": 25,
                "fertilizers": [
                    {"name": "IFFCO Urea", "npk": "46-0-0", "quantity_per_acre": 50, "unit": "kg"}
                ]
            },
            {
                "stage": "Panicle Initiation (50 Days)",
                "timing_days": 50,
                "fertilizers": [
                    {"name": "IFFCO Urea", "npk": "46-0-0", "quantity_per_acre": 35, "unit": "kg"}
                ]
            }
        ],
        
        "irrigation_schedule": {
            "nursery": {"frequency_days": 2, "water_mm": 30},
            "vegetative": {"frequency_days": 3, "water_mm": 50},
            "reproductive": {"frequency_days": 3, "water_mm": 60},
            "maturity": {"frequency_days": 5, "water_mm": 40}
        },
        
        "common_diseases": {
            "blast": {
                "symptoms": ["diamond-shaped lesions", "leaf spots", "neck blast"],
                "treatment_chemical": "Tricyclazole @ 0.6g/liter or Carbendazim @ 1g/liter",
                "treatment_organic": "Pseudomonas fluorescens @ 10g/liter",
                "prevention": ["Resistant varieties", "Balanced fertilization", "Avoid excess nitrogen"]
            },
            "bacterial_leaf_blight": {
                "symptoms": ["water-soaked lesions", "yellow to white leaves", "wilting"],
                "treatment_chemical": "Copper hydroxide @ 2g/liter",
                "treatment_organic": "Neem oil @ 5ml/liter",
                "prevention": ["Use certified seeds", "Proper water management"]
            }
        },
        
        "harvest_indicators": {
            "maturity_days": 120,
            "physical_signs": ["80% grains turned golden", "Moisture content 20-25%", "Drooping panicles"]
        },
        
        "market_calendar": {
            "peak_demand_months": [10, 11, 12, 1],
            "avg_price_per_quintal": 2000,
            "price_variation": {"peak": 2200, "off_season": 1800}
        },
        
        "expected_yield": {"min": 20, "max": 30, "unit": "quintals/acre"}
    },
    
    "jowar": {
        "marathi_name": "ज्वारी",
        "scientific_name": "Sorghum bicolor",
        "varieties": ["CSH-16", "Parbhani Moti", "M-35-1", "Phule Yasoda"],
        "duration_months": 4,
        "seasons": ["Kharif (June-October)", "Rabi (October-March)"],
        
        "soil_requirements": {
            "optimal_ph": {"min": 6.0, "max": 8.5},
            "soil_types": ["Black", "Red", "Loamy"],
            "npk_requirements": {
                "nitrogen": {"min": 80, "max": 100},
                "phosphorus": {"min": 40, "max": 50},
                "potassium": {"min": 30, "max": 40}
            }
        },
        
        "fertilization_schedule": [
            {
                "stage": "Sowing",
                "timing_days": 0,
                "fertilizers": [
                    {"name": "IFFCO DAP", "npk": "18-46-0", "quantity_per_acre": 30, "unit": "kg"},
                    {"name": "Potash", "npk": "0-0-60", "quantity_per_acre": 15, "unit": "kg"}
                ]
            },
            {
                "stage": "30 Days After Sowing",
                "timing_days": 30,
                "fertilizers": [
                    {"name": "IFFCO Urea", "npk": "46-0-0", "quantity_per_acre": 40, "unit": "kg"}
                ]
            }
        ],
        
        "irrigation_schedule": {
            "sowing": {"frequency_days": 10, "water_mm": 40},
            "vegetative": {"frequency_days": 12, "water_mm": 50},
            "flowering": {"frequency_days": 10, "water_mm": 60},
            "grain_filling": {"frequency_days": 12, "water_mm": 45}
        },
        
        "common_diseases": {
            "grain_mold": {
                "symptoms": ["discolored grains", "moldy appearance", "reduced quality"],
                "treatment_chemical": "Mancozeb @ 2g/liter",
                "treatment_organic": "Dry the grains properly, sun drying",
                "prevention": ["Harvest at right moisture", "Proper storage"]
            },
            "downy_mildew": {
                "symptoms": ["white downy growth", "leaf stripes", "stunting"],
                "treatment_chemical": "Metalaxyl @ 2g/kg seed treatment",
                "treatment_organic": "Remove infected plants",
                "prevention": ["Resistant varieties", "Seed treatment"]
            }
        },
        
        "harvest_indicators": {
            "maturity_days": 110,
            "physical_signs": ["Grains hard and dry", "Leaves turn yellow", "Moisture below 20%"]
        },
        
        "market_calendar": {
            "peak_demand_months": [10, 11, 1, 2],
            "avg_price_per_quintal": 2800,
            "price_variation": {"peak": 3000, "off_season": 2600}
        },
        
        "expected_yield": {"min": 10, "max": 15, "unit": "quintals/acre"}
    },
    
    "wheat": {
        "marathi_name": "गहू",
        "scientific_name": "Triticum aestivum",
        "varieties": ["HD-2967", "Lok-1", "NIAW-301", "Phule Samrudhi"],
        "duration_months": 4,
        "seasons": ["Rabi (November-March)"],
        
        "soil_requirements": {
            "optimal_ph": {"min": 6.0, "max": 7.5},
            "soil_types": ["Loamy", "Clayey", "Black"],
            "npk_requirements": {
                "nitrogen": {"min": 100, "max": 120},
                "phosphorus": {"min": 50, "max": 60},
                "potassium": {"min": 40, "max": 50}
            }
        },
        
        "fertilization_schedule": [
            {
                "stage": "Sowing",
                "timing_days": 0,
                "fertilizers": [
                    {"name": "IFFCO DAP", "npk": "18-46-0", "quantity_per_acre": 35, "unit": "kg"},
                    {"name": "Potash", "npk": "0-0-60", "quantity_per_acre": 20, "unit": "kg"}
                ]
            },
            {
                "stage": "First Irrigation (21 Days)",
                "timing_days": 21,
                "fertilizers": [
                    {"name": "IFFCO Urea", "npk": "46-0-0", "quantity_per_acre": 50, "unit": "kg"}
                ]
            },
            {
                "stage": "Second Irrigation (40 Days)",
                "timing_days": 40,
                "fertilizers": [
                    {"name": "IFFCO Urea", "npk": "46-0-0", "quantity_per_acre": 30, "unit": "kg"}
                ]
            }
        ],
        
        "irrigation_schedule": {
            "crown_root_initiation": {"frequency_days": 21, "water_mm": 50},
            "tillering": {"frequency_days": 15, "water_mm": 50},
            "jointing": {"frequency_days": 15, "water_mm": 60},
            "flowering": {"frequency_days": 12, "water_mm": 60},
            "milk_stage": {"frequency_days": 12, "water_mm": 50},
            "dough_stage": {"frequency_days": 15, "water_mm": 40}
        },
        
        "common_diseases": {
            "rust": {
                "symptoms": ["orange-brown pustules", "leaf yellowing", "reduced vigor"],
                "treatment_chemical": "Propiconazole @ 1ml/liter",
                "treatment_organic": "Sulfur dust @ 25kg/acre",
                "prevention": ["Resistant varieties", "Timely sowing", "Proper spacing"]
            },
            "loose_smut": {
                "symptoms": ["black powdery mass in ears", "destroyed grains"],
                "treatment_chemical": "Carboxin @ 2g/kg seed treatment",
                "treatment_organic": "Hot water seed treatment at 52°C for 10 min",
                "prevention": ["Certified seeds", "Seed treatment"]
            }
        },
        
        "harvest_indicators": {
            "maturity_days": 120,
            "physical_signs": ["Golden yellow color", "Grains hard", "Moisture 20-22%"]
        },
        
        "market_calendar": {
            "peak_demand_months": [3, 4, 5],
            "avg_price_per_quintal": 2125,  # MSP 2026
            "price_variation": {"peak": 2200, "off_season": 2000}
        },
        
        "expected_yield": {"min": 15, "max": 20, "unit": "quintals/acre"}
    },
    
    "tur": {
        "marathi_name": "तूर",
        "scientific_name": "Cajanus cajan",
        "varieties": ["BDN-716", "Vipula", "Phule T-9", "ICPL-87119"],
        "duration_months": 6,
        "seasons": ["Kharif (June-December)"],
        
        "soil_requirements": {
            "optimal_ph": {"min": 6.5, "max": 7.5},
            "soil_types": ["Black", "Red", "Loamy"],
            "npk_requirements": {
                "nitrogen": {"min": 20, "max": 25},  # Less nitrogen as it's legume
                "phosphorus": {"min": 50, "max": 60},
                "potassium": {"min": 25, "max": 30}
            }
        },
        
        "fertilization_schedule": [
            {
                "stage": "Sowing",
                "timing_days": 0,
                "fertilizers": [
                    {"name": "IFFCO DAP", "npk": "18-46-0", "quantity_per_acre": 30, "unit": "kg"},
                    {"name": "Potash", "npk": "0-0-60", "quantity_per_acre": 12, "unit": "kg"}
                ]
            },
            {
                "stage": "Flowering (60 Days)",
                "timing_days": 60,
                "fertilizers": [
                    {"name": "IFFCO Urea", "npk": "46-0-0", "quantity_per_acre": 10, "unit": "kg"}
                ]
            }
        ],
        
        "irrigation_schedule": {
            "germination": {"frequency_days": 15, "water_mm": 40},
            "vegetative": {"frequency_days": 20, "water_mm": 50},
            "flowering": {"frequency_days": 15, "water_mm": 50},
            "pod_filling": {"frequency_days": 12, "water_mm": 50}
        },
        
        "common_diseases": {
            "wilt": {
                "symptoms": ["yellowing of leaves", "drooping", "wilting of entire plant"],
                "treatment_chemical": "Carbendazim @ 2g/liter soil drench",
                "treatment_organic": "Trichoderma @ 5g/liter soil application",
                "prevention": ["Resistant varieties", "Crop rotation", "Seed treatment"]
            },
            "pod_borer": {
                "symptoms": ["holes in pods", "caterpillars inside", "damaged grains"],
                "treatment_chemical": "Quinalphos @ 2ml/liter",
                "treatment_organic": "Bacillus thuringiensis @ 2g/liter",
                "prevention": ["Pheromone traps", "Bird perches", "Neem spray"]
            }
        },
        
        "harvest_indicators": {
            "maturity_days": 180,
            "physical_signs": ["Pods turn brown", "Leaves fall", "Dry rattling sound from pods"]
        },
        
        "market_calendar": {
            "peak_demand_months": [12, 1, 2],
            "avg_price_per_quintal": 7000,  # MSP 2026
            "price_variation": {"peak": 7500, "off_season": 6500}
        },
        
        "expected_yield": {"min": 6, "max": 10, "unit": "quintals/acre"}
    },
    
    "soybean": {
        "marathi_name": "सोयाबीन",
        "scientific_name": "Glycine max",
        "varieties": ["JS-335", "MAUS-71", "Phule Kalyani", "JS-95-60"],
        "duration_months": 3.5,
        "seasons": ["Kharif (June-October)"],
        
        "soil_requirements": {
            "optimal_ph": {"min": 6.5, "max": 7.0},
            "soil_types": ["Black", "Red", "Alluvial"],
            "npk_requirements": {
                "nitrogen": {"min": 20, "max": 30},
                "phosphorus": {"min": 60, "max": 80},
                "potassium": {"min": 30, "max": 40}
            }
        },
        
        "fertilization_schedule": [
            {
                "stage": "Sowing",
                "timing_days": 0,
                "fertilizers": [
                    {"name": "IFFCO DAP", "npk": "18-46-0", "quantity_per_acre": 45, "unit": "kg"},
                    {"name": "Potash", "npk": "0-0-60", "quantity_per_acre": 15, "unit": "kg"}
                ]
            },
            {
                "stage": "Flowering (35 Days)",
                "timing_days": 35,
                "fertilizers": [
                    {"name": "IFFCO Urea", "npk": "46-0-0", "quantity_per_acre": 12, "unit": "kg"}
                ]
            }
        ],
        
        "irrigation_schedule": {
            "germination": {"frequency_days": 10, "water_mm": 40},
            "vegetative": {"frequency_days": 12, "water_mm": 50},
            "flowering": {"frequency_days": 10, "water_mm": 60},
            "pod_filling": {"frequency_days": 10, "water_mm": 50}
        },
        
        "common_diseases": {
            "yellow_mosaic_virus": {
                "symptoms": ["yellow mottling on leaves", "stunted growth", "reduced pods"],
                "treatment_chemical": "Control whitefly vector with Imidacloprid @ 0.3ml/liter",
                "treatment_organic": "Neem oil spray @ 5ml/liter",
                "prevention": ["Resistant varieties", "Control whitefly", "Remove infected plants"]
            },
            "rust": {
                "symptoms": ["reddish-brown pustules", "leaf drop", "yield loss"],
                "treatment_chemical": "Hexaconazole @ 1ml/liter",
                "treatment_organic": "Sulfur dust @ 20kg/acre",
                "prevention": ["Timely sowing", "Resistant varieties"]
            }
        },
        
        "harvest_indicators": {
            "maturity_days": 100,
            "physical_signs": ["75% pods brown", "Leaves fall", "Rattling pods"]
        },
        
        "market_calendar": {
            "peak_demand_months": [10, 11, 12],
            "avg_price_per_quintal": 4600,  # MSP 2026
            "price_variation": {"peak": 4800, "off_season": 4400}
        },
        
        "expected_yield": {"min": 8, "max": 12, "unit": "quintals/acre"}
    },
    
    "groundnut": {
        "marathi_name": "भुईमूग",
        "scientific_name": "Arachis hypogaea",
        "varieties": ["TAG-24", "Phule Pragati", "JL-24", "Konkan Gaurav"],
        "duration_months": 4,
        "seasons": ["Kharif (June-October)", "Summer (February-May)"],
        
        "soil_requirements": {
            "optimal_ph": {"min": 6.0, "max": 6.5},
            "soil_types": ["Sandy Loam", "Red", "Black"],
            "npk_requirements": {
                "nitrogen": {"min": 25, "max": 30},
                "phosphorus": {"min": 50, "max": 70},
                "potassium": {"min": 40, "max": 50}
            }
        },
        
        "fertilization_schedule": [
            {
                "stage": "Sowing",
                "timing_days": 0,
                "fertilizers": [
                    {"name": "IFFCO DAP", "npk": "18-46-0", "quantity_per_acre": 40, "unit": "kg"},
                    {"name": "Potash", "npk": "0-0-60", "quantity_per_acre": 20, "unit": "kg"},
                    {"name": "Gypsum", "npk": "0-0-0", "quantity_per_acre": 100, "unit": "kg"}  # For calcium
                ]
            },
            {
                "stage": "Flowering (30 Days)",
                "timing_days": 30,
                "fertilizers": [
                    {"name": "IFFCO Urea", "npk": "46-0-0", "quantity_per_acre": 12, "unit": "kg"}
                ]
            }
        ],
        
        "irrigation_schedule": {
            "germination": {"frequency_days": 5, "water_mm": 30},
            "vegetative": {"frequency_days": 10, "water_mm": 40},
            "pegging": {"frequency_days": 7, "water_mm": 50},
            "pod_development": {"frequency_days": 7, "water_mm": 50},
            "maturity": {"frequency_days": 12, "water_mm": 30}
        },
        
        "common_diseases": {
            "tikka_disease": {
                "symptoms": ["circular brown spots", "concentric rings", "leaf drop"],
                "treatment_chemical": "Mancozeb @ 2.5g/liter",
                "treatment_organic": "Copper oxychloride @ 3g/liter",
                "prevention": ["Resistant varieties", "Crop rotation", "Proper spacing"]
            },
            "collar_rot": {
                "symptoms": ["rotting at soil level", "wilting", "yellowing"],
                "treatment_chemical": "Carbendazim @ 2g/liter soil drench",
                "treatment_organic": "Trichoderma viride @ 5g/liter",
                "prevention": ["Seed treatment", "Avoid waterlogging", "Crop rotation"]
            }
        },
        
        "harvest_indicators": {
            "maturity_days": 120,
            "physical_signs": ["Yellow leaves", "Brown pod shells", "Dark veination on pods"]
        },
        
        "market_calendar": {
            "peak_demand_months": [10, 11, 12, 3, 4],
            "avg_price_per_quintal": 6100,  # MSP 2026
            "price_variation": {"peak": 6500, "off_season": 5800}
        },
        
        "expected_yield": {"min": 10, "max": 15, "unit": "quintals/acre"}
    },
    
    "sunflower": {
        "marathi_name": "सूर्यफूल",
        "scientific_name": "Helianthus annuus",
        "varieties": ["KBSH-44", "Phule Bhaskar", "LSFH-171", "Bhanu"],
        "duration_months": 3,
        "seasons": ["Kharif (June-September)", "Rabi (October-January)", "Summer (February-May)"],
        
        "soil_requirements": {
            "optimal_ph": {"min": 6.5, "max": 8.0},
            "soil_types": ["Black", "Red", "Alluvial"],
            "npk_requirements": {
                "nitrogen": {"min": 60, "max": 80},
                "phosphorus": {"min": 40, "max": 60},
                "potassium": {"min": 40, "max": 50}
            }
        },
        
        "fertilization_schedule": [
            {
                "stage": "Sowing",
                "timing_days": 0,
                "fertilizers": [
                    {"name": "IFFCO DAP", "npk": "18-46-0", "quantity_per_acre": 35, "unit": "kg"},
                    {"name": "Potash", "npk": "0-0-60", "quantity_per_acre": 20, "unit": "kg"}
                ]
            },
            {
                "stage": "30 Days After Sowing",
                "timing_days": 30,
                "fertilizers": [
                    {"name": "IFFCO Urea", "npk": "46-0-0", "quantity_per_acre": 35, "unit": "kg"}
                ]
            }
        ],
        
        "irrigation_schedule": {
            "germination": {"frequency_days": 5, "water_mm": 30},
            "vegetative": {"frequency_days": 10, "water_mm": 40},
            "flowering": {"frequency_days": 7, "water_mm": 50},
            "seed_filling": {"frequency_days": 7, "water_mm": 50},
            "maturity": {"frequency_days": 12, "water_mm": 30}
        },
        
        "common_diseases": {
            "alternaria_blight": {
                "symptoms": ["dark brown spots", "concentric rings", "leaf blight"],
                "treatment_chemical": "Mancozeb @ 2.5g/liter",
                "treatment_organic": "Neem oil @ 5ml/liter",
                "prevention": ["Resistant varieties", "Crop rotation", "Destroy crop residue"]
            },
            "downy_mildew": {
                "symptoms": ["white downy growth", "pale green areas", "stunting"],
                "treatment_chemical": "Metalaxyl @ 2g/liter",
                "treatment_organic": "Remove and destroy infected plants",
                "prevention": ["Seed treatment", "Avoid overhead irrigation"]
            }
        },
        
        "harvest_indicators": {
            "maturity_days": 90,
            "physical_signs": ["Back of head turns yellow-brown", "Bracts turn brown", "Moisture 18-20%"]
        },
        
        "market_calendar": {
            "peak_demand_months": [1, 2, 3, 9, 10],
            "avg_price_per_quintal": 6760,  # MSP 2026
            "price_variation": {"peak": 7000, "off_season": 6500}
        },
        
        "expected_yield": {"min": 8, "max": 12, "unit": "quintals/acre"}
    },
    
    "gram": {
        "marathi_name": "हरभरा",
        "scientific_name": "Cicer arietinum",
        "varieties": ["Vijay", "Virat", "Digvijay", "Phule G-5"],
        "duration_months": 4,
        "seasons": ["Rabi (October-February)"],
        
        "soil_requirements": {
            "optimal_ph": {"min": 6.0, "max": 7.5},
            "soil_types": ["Black", "Loamy", "Clayey"],
            "npk_requirements": {
                "nitrogen": {"min": 20, "max": 25},
                "phosphorus": {"min": 40, "max": 50},
                "potassium": {"min": 20, "max": 25}
            }
        },
        
        "fertilization_schedule": [
            {
                "stage": "Sowing",
                "timing_days": 0,
                "fertilizers": [
                    {"name": "IFFCO DAP", "npk": "18-46-0", "quantity_per_acre": 30, "unit": "kg"},
                    {"name": "Potash", "npk": "0-0-60", "quantity_per_acre": 10, "unit": "kg"}
                ]
            },
            {
                "stage": "Flowering (40 Days)",
                "timing_days": 40,
                "fertilizers": [
                    {"name": "IFFCO Urea", "npk": "46-0-0", "quantity_per_acre": 10, "unit": "kg"}
                ]
            }
        ],
        
        "irrigation_schedule": {
            "pre_sowing": {"frequency_days": 0, "water_mm": 50},
            "flowering": {"frequency_days": 35, "water_mm": 50},
            "pod_filling": {"frequency_days": 25, "water_mm": 50}
        },
        
        "common_diseases": {
            "wilt": {
                "symptoms": ["yellowing", "drooping", "wilting", "vascular browning"],
                "treatment_chemical": "Carbendazim @ 2g/liter soil drench",
                "treatment_organic": "Trichoderma @ 5g/liter",
                "prevention": ["Resistant varieties", "Seed treatment", "Crop rotation"]
            },
            "pod_borer": {
                "symptoms": ["holes in pods", "damaged seeds", "webbing"],
                "treatment_chemical": "Quinalphos @ 2ml/liter",
                "treatment_organic": "Bacillus thuringiensis @ 2g/liter, Neem seed kernel extract",
                "prevention": ["Pheromone traps", "Early sowing", "Deep summer ploughing"]
            }
        },
        
        "harvest_indicators": {
            "maturity_days": 110,
            "physical_signs": ["Pods turn brown", "Leaves dry and fall", "Seeds hard"]
        },
        
        "market_calendar": {
            "peak_demand_months": [2, 3, 4],
            "avg_price_per_quintal": 5440,  # MSP 2026
            "price_variation": {"peak": 5800, "off_season": 5200}
        },
        
        "expected_yield": {"min": 6, "max": 10, "unit": "quintals/acre"}
    }
}


# Government subsidized fertilizer brands with prices (₹ per 50kg bag)
FERTILIZER_PRICES = {
    "IFFCO Urea": {"npk": "46-0-0", "price": 242},
    "IFFCO DAP": {"npk": "18-46-0", "price": 1310},
    "NFL Urea": {"npk": "46-0-0", "price": 242},
    "NFL DAP": {"npk": "18-46-0", "price": 1300},
    "RCF Urea": {"npk": "46-0-0", "price": 242},
    "RCF DAP": {"npk": "18-46-0", "price": 1310},
    "Potash": {"npk": "0-0-60", "price": 850},
    "Gypsum": {"npk": "0-0-0", "price": 200}
}


def get_crop_data(crop_name: str) -> Optional[Dict]:
    """
    Get complete crop data by name (case-insensitive)
    1. Check static database
    2. Check dynamic knowledge service (search & store)
    """
    crop_name_lower = crop_name.lower().strip()
    
    # 1. Check static DB
    if crop_name_lower in CROP_DATABASE:
        return CROP_DATABASE[crop_name_lower]
        
    # 2. Check Dynamic Service
    try:
        from app.services.dynamic_knowledge_service import dynamic_knowledge_service
        return dynamic_knowledge_service.fetch_and_store(crop_name)
    except ImportError:
        # Fallback if service not available (e.g. tests)
        return None
    except Exception as e:
        print(f"Error fetching dynamic data for {crop_name}: {e}")
        return None


def get_all_crop_names() -> List[str]:
    """Get list of all supported crop names (static + dynamic)"""
    names = list(CROP_DATABASE.keys())
    
    # Add dynamic names
    try:
        from app.services.dynamic_knowledge_service import dynamic_knowledge_service
        names.extend(list(dynamic_knowledge_service.dynamic_knowledge.keys()))
    except:
        pass
        
    return sorted(list(set(names)))


def match_crop_to_soil(soil_npk: Dict[str, float], current_month: int = None) -> List[Dict]:
    """
    Match crops to soil NPK values and season
    Returns list of crops with suitability scores
    """
    if current_month is None:
        current_month = datetime.now().month
    
    results = []
    
    for crop_name, crop_data in CROP_DATABASE.items():
        score = 0
        reasons = []
        
        # NPK matching (40% weightage)
        npk_req = crop_data["soil_requirements"]["npk_requirements"]
        n_match = is_npk_in_range(soil_npk.get("nitrogen", 0), npk_req["nitrogen"])
        p_match = is_npk_in_range(soil_npk.get("phosphorus", 0), npk_req["phosphorus"])
        k_match = is_npk_in_range(soil_npk.get("potassium", 0), npk_req["potassium"])
        
        npk_score = (n_match + p_match + k_match) / 3 * 40
        score += npk_score
        
        if npk_score > 30:
            reasons.append(f"Good NPK match (Score: {npk_score:.0f}/40)")
        
        # Season matching (30% weightage)
        season_match = is_season_suitable(crop_data["seasons"], current_month)
        season_score = 30 if season_match else 10
        score += season_score
        
        if season_match:
            reasons.append("Suitable season for planting")
        
        # Market price (30% weightage) - higher price = better
        avg_price = crop_data["market_calendar"].get("avg_price_per_quintal", crop_data["market_calendar"].get("avg_price_per_ton", 0))
        market_score = min(30, (avg_price / 10000) * 30)  # Normalize
        score += market_score
        
        if market_score > 20:
            reasons.append(f"Good market price (₹{avg_price})")
        
        results.append({
            "crop_name": crop_name,
            "marathi_name": crop_data["marathi_name"],
            "suitability_score": round(score, 1),
            "reasons": reasons,
            "expected_yield": crop_data["expected_yield"],
            "duration_months": crop_data["duration_months"],
            "avg_price": avg_price
        })
    
    # Sort by suitability score
    results.sort(key=lambda x: x["suitability_score"], reverse=True)
    return results


def is_npk_in_range(value: float, req_range: Dict[str, float], tolerance: float = 0.15) -> float:
    """
    Check if NPK value is within required range with tolerance
    Returns score 0-1
    """
    min_val = req_range["min"] * (1 - tolerance)
    max_val = req_range["max"] * (1 + tolerance)
    optimal = (req_range["min"] + req_range["max"]) / 2
    
    if min_val <= value <= max_val:
        # Calculate how close to optimal
        distance = abs(value - optimal) / optimal
        return max(0.7, 1 - distance)  # Minimum 0.7 if in range
    else:
        # Outside range
        if value < min_val:
            distance = (min_val - value) / min_val
        else:
            distance = (value - max_val) / max_val
        return max(0, 1 - distance)


def is_season_suitable(seasons: List[str], month: int) -> bool:
    """Check if current month is suitable for planting"""
    season_months = {
        "kharif": [6, 7, 8],  # June-Aug
        "rabi": [10, 11, 12],  # Oct-Dec
        "summer": [2, 3, 4],  # Feb-Apr
        "year-round": list(range(1, 13))
    }
    
    for season_desc in seasons:
        season_lower = season_desc.lower()
        for season_key, months in season_months.items():
            if season_key in season_lower and month in months:
                return True
    return False


def get_fertilizer_price(fertilizer_name: str) -> int:
    """Get price of fertilizer per 50kg"""
    return FERTILIZER_PRICES.get(fertilizer_name, {}).get("price", 0)


def calculate_days_from_stage(crop_name: str, stage_name: str) -> int:
    """Calculate days from sowing to a particular stage"""
    crop_data = get_crop_data(crop_name)
    if not crop_data:
        return 0
    
    for fert_schedule in crop_data.get("fertilization_schedule", []):
        if stage_name.lower() in fert_schedule["stage"].lower():
            return fert_schedule["timing_days"]
    
    return 0
