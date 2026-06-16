from fastapi import APIRouter, Query
from datetime import datetime
import hashlib

router = APIRouter()

# Daily predictions templates to generate high quality, rich predictions dynamically
CAREER_TIPS = [
    "A great day for collaborative projects. Your ideas will be well received by peers.",
    "Avoid making major financial commitments or signing new contracts today.",
    "A busy day ahead with meetings. Stay focused and prioritize your tasks.",
    "Your hard work is noticed by superiors. A promotion or recognition is on the horizon.",
    "A perfect time to upskill. Focus on learning new technologies or methods.",
    "Keep communication clear at work. A misunderstandings could arise with co-workers.",
]

LOVE_TIPS = [
    "Clear communication will resolve any misunderstandings with your partner today.",
    "A romantic evening lies ahead. Plan a surprise dinner or simple walk together.",
    "Single natives may encounter someone intriguing during a social gathering.",
    "Focus on building trust and spending quality time at home with family.",
    "Express your feelings openly. Your emotional transparency will strengthen bonds.",
    "Give your partner some space today. Patience will strengthen your connection.",
]

HEALTH_TIPS = [
    "Drink plenty of water and maintain a balanced diet. Avoid processed foods today.",
    "Focus on mental wellness. Spend 15 minutes meditating or practicing yoga.",
    "You may feel a bit low on energy. Take adequate rest and avoid overexerting.",
    "A great day for outdoor physical activities. A light run or stretch will boost energy.",
    "Pay attention to your posture today to prevent minor back or neck strain.",
    "A refreshing sleep will cure today's fatigue. Avoid screen time before bed.",
]

FINANCE_TIPS = [
    "A good day for investments in stable instruments. Avoid speculative trading.",
    "Expenses might rise today due to household needs. Manage your budget carefully.",
    "Unexpected financial gains or returns from past investments are likely today.",
    "A favorable period for planning long-term wealth assets and savings.",
    "Lending money today should be avoided to prevent future relationship stress.",
    "A small bonus or cash gift is headed your way. Put it into your savings.",
]

LUCKY_COLORS = ["Red", "Blue", "Green", "Yellow", "Orange", "Pink", "White", "Violet", "Gold", "Silver"]

@router.get("/horoscope")
def get_horoscope(rashi: str = Query(..., description="Name of the Rashi")):
    today_str = datetime.utcnow().strftime("%Y-%m-%d")
    
    # Hash seed to guarantee consistency for a Rashi on a specific day
    combined_str = f"{rashi.lower()}_{today_str}"
    hash_val = int(hashlib.md5(combined_str.encode('utf-8')).hexdigest(), 16)
    
    # Select predictions deterministically based on hash value
    career = CAREER_TIPS[hash_val % len(CAREER_TIPS)]
    love = LOVE_TIPS[(hash_val >> 1) % len(LOVE_TIPS)]
    health = HEALTH_TIPS[(hash_val >> 2) % len(HEALTH_TIPS)]
    finance = FINANCE_TIPS[(hash_val >> 3) % len(FINANCE_TIPS)]
    
    lucky_num = (hash_val % 9) + 1
    lucky_color = LUCKY_COLORS[(hash_val >> 4) % len(LUCKY_COLORS)]
    
    overview = (
        f"Today, {rashi} natives will experience a balance of positive celestial energies. "
        "Your planetary alignments favor steady progress and clear-headed decision making. "
        "Maintain your focus, listen to your inner intuition, and avoid impulsive arguments."
    )
    
    return {
        "success": True,
        "rashi": rashi,
        "date": today_str,
        "horoscope": {
            "overview": overview,
            "career": career,
            "love": love,
            "health": health,
            "finance": finance,
            "lucky_number": lucky_num,
            "lucky_color": lucky_color
        }
    }
