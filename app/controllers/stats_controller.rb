require 'httparty'

class StatsController < ApplicationController
    def stats
        response = HTTParty.get('https://youtubeanalytics.googleapis.com/v2/reports?endDate=2014-06-30&ids=channel%3D%3DMINE&metrics=views%2Ccomments%2Clikes%2Cdislikes%2CestimatedMinutesWatched%2CaverageViewDuration&startDate=2014-05-01&key=AIzaSyAuKyozeuO0F-fcLNdKTVbVuhSYaW8cau4 HTTP/1.1')
        @resp_code=response.code
        @resp_body=response.body
    end
end
