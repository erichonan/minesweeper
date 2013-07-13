import logging
from google.appengine.ext import ndb
import json
import webapp2


# This script just needs to accept two values:
# SCORE and NAME

#first receive post data and log it

#first access scope

#add ability to add high score to page
#HIGH_SCORES_FOOTER = """\
#		<form action="/" method="post">
#			<div>user <input type="text" name="username"></div>
#			<div>time <input type="text" name="time"></div>
#			<div><input type="submit" value="post score"></div>
#		</form>
#		<form action="/getScores" method="post">
#			<div><input type="submit" value="see scores"></div>
#		</form>
#	</body>
#</html>
#"""

DEFAULT_SCOREBOARD_NAME = 'default_scoreboard'

def scoreboard_key(scoreboard_name=DEFAULT_SCOREBOARD_NAME):
	return nbd.Key('ScoreBoard', scoreboard_name)

#return top ten high scores
class HighScore(ndb.Model):
	"""Models an individual higscore entry with player and score"""
	playerName = ndb.StringProperty()
	score = ndb.StringProperty()


class MainPage(webapp2.RequestHandler):
	def get(self):
		logging.info('MainPage GET function called')
		#self.response.write('<p>testing</p>') #this will have to be json
		#highscores_name = self.request.get('highscores_name', DEFAULT_SCORE_BOARD_NAME)
		#self.response.write('<html><body>')

		scoreboard_name = self.request.get('scoreboard_name', DEFAULT_SCOREBOARD_NAME)
		logging.info('setting scoreboard_name here: %s' % scoreboard_name)
		
		#self.response.write(HIGH_SCORES_FOOTER)


	def post(self):
		logging.info('MainPage POST function called')

		#highscore = HighScore(parent=scoreboard_key(scoreboard_name))
		highscore = HighScore()
		highscore.playerName = self.request.get('username') #HC_USER #self.request.get('content')
		highscore.score = self.request.get('time')
		highscore.put()

		self.response.write("playerName = %s and score = %s" % (highscore.playerName, highscore.score))


class GetScores(webapp2.RequestHandler):

	def get(self):
		#scoreboard_name = self.request.get('scoreboard_name', DEFAULT_SCOREBOARD_NAME)
		#first print out a set of bogus scores
		#write first score in first field

		scores_query = HighScore.query().order(HighScore.score)
		highscores = scores_query.fetch(10)

		# I should be able to find a better way to encode JSON
		results = "["

		for i, highScore in enumerate(highscores):
			results = results + json.dumps(highScore.to_dict())
			if i < len(highscores) - 1:
				 results = results + ", "
				 logging.info("i = %i" % i)

		results = results + "]"

		#highscoresJSON = json.dumps(highscores[0].to_dict())
		self.response.write(results)


		#eventually return array of scores

application = webapp2.WSGIApplication([
	('/', MainPage),
	('/getScores', GetScores)
	], debug=True)


