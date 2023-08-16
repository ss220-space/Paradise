from flask import Flask, json
from flask import request
from tts_processor import tts_creator

api = Flask(__name__)
primary_speaker = 'aidar'


#Packaging response into Silero API-like format
def build_response(audio):
   results = [{'chunk_len' : 0, 'chunk_text' : "string", "audio" : audio, "world_align" : [None]}]
   original_sha1 = "string"
   remote_id = "string"
   timings = {}
   payload = {
      'results': results,
      'original_sha1': original_sha1,
      'remode_id': remote_id,
      'timings': timings
   }
   return payload

#Get request, consume text, make tts, build response, return to sender.
@api.route('/tts/', methods=['POST'])
def process_tts():
   request_data = request.get_json()
   text = request_data['text']
   original_speaker = request_data['speaker']
   print(f'Got request with text "{text}" and speaker: "{original_speaker}"') #Strictly debugging thing, uncomment if uncomfortable.
   sample_rate = request_data['sample_rate']
   speaker = primary_speaker
   tts_module = tts_creator()
   payload = build_response(tts_module.make_ogg_base64(text=text, speaker=speaker, sample_rate=sample_rate))
   return json.dumps(payload)

if __name__ == '__main__':
    api.run()