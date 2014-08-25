import cgi
import json

from google.appengine.ext import ndb

import webapp2

DEFAULT_LOG_HTML = """\
<html>
	<body>
		<p>username = %s</p>
		<p>score = %s</p>
	</body>
</html>
"""

class Score(ndb.Model):
	username = ndb.StringProperty(indexed=False)
	score = ndb.StringProperty(indexed=False)

class ScoreBoard(webapp2.RequestHandler):
	def get(self):
		self.response.headers['Content-Type'] = 'text/html'
		# now print all scores in datastore
		scores_query = Score.query()
		scores = scores_query.fetch(10)

		for score in scores:
			convertedScore = int(score.score)
			self.response.write('<p>user:%s :: score: %s</p>' % (score.username, convertedScore))

class LogScore(webapp2.RequestHandler):
	def post(self):
		self.response.headers['Content-Type'] = 'text/plain'

		# porting code from tutorial
		score = Score()

		score.score = self.request.get('score')
		score.username = self.request.get('username')
		score.put()

application = webapp2.WSGIApplication([
	('/', ScoreBoard),
	('/log', LogScore)],
	debug=True)
