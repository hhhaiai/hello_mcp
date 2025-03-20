import requests

CITY_CODES = {
  "北京": {
    "北京": {
      "AREAID": "101010100"
    }
  },
  "上海": {
    "上海": {
      "AREAID": "101020100"
    }
  },
  "天津": {
    "天津": {
      "AREAID": "101030100"
    }
  },
  "重庆": {
    "重庆": {
      "AREAID": "101040100"
    }
  }
}

def get_weather(city):
    try:
        area_id = CITY_CODES[city][city]['AREAID']
        url = f'http://t.weather.itboy.net/api/weather/city/{area_id}'
        response = requests.get(url)
        response.raise_for_status()
        return response.json()
    except KeyError:
        return {'error': 'City not found'}
    except requests.exceptions.RequestException as e:
        return {'error': str(e)}

if __name__ == '__main__':
    city = input('Enter city name: ')
    weather = get_weather(city)
    print(weather)