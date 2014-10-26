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

		#self.response.write(scores);

		array_of_scores = [];
		for score in scores:
			#self.response.write('<p>user:%s :: score: %s</p>' % (score.username, score.score))
			array_of_scores.append({"username":score.username, "score":score.score});

		self.response.write(len(array_of_scores))
		json_export = json.dumps(array_of_scores)

		self.response.write(json_export)

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
