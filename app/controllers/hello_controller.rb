require 'uri'
require 'csv'
require 'net/http'

class HelloController < ApplicationController

  @@body = []

  def index
    token = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOjUsImp0aSI6Mjk2LCJpYXQiOjE3MTY2MTU5NDQsImV4cCI6MjAzMjE0ODc0NH0.zXDFLSmytlR_TgKhj73i744XnelwcqoT9YrhOvtfEMk"
    api_relationships = "https://app.parma.ai/api/v1/relationships"
    final_token = 'Bearer ' + token
    uri_relationships = URI.parse(api_relationships)
    response_relationship = Net::HTTP.get_response(uri_relationships, {'Accept' => 'application/json', 'Authorization' => final_token})
    response_json = JSON.parse(response_relationship.body)

    arr = []
    rel = Hash.new("relationships")

    replacements = {',' => ';', '-' => ''}
    

    for data in response_json["data"] do
      id = data["id"]
      rel[id] = data["name"]
    end

    for data in response_json["data"] do
      id = data["id"]

      api_notes = "https://app.parma.ai/api/v1/relationships/#{id}/notes";
      uri_notes = URI.parse(api_notes)
      response_notes = Net::HTTP.get_response(uri_notes, {'Accept' => 'application/json', 'Authorization' => final_token})
      response_notes_json = JSON.parse(response_notes.body)

      if response_notes_json["data"].length !=0
        for elem in response_notes_json["data"]
          dt = []
          elem["body"] = elem["body"].gsub(Regexp.union(replacements.keys), replacements)
          for ids in elem["relationship_ids"]
            dt.push([ids, rel[ids]])
          end
          elem["relationship_ids"] = dt
          arr.push(elem)
        end
      end
    end

    @@body = arr
    @body = arr
  end

  def export_csv
    @body = @@body
    respond_to do |format|
      format.csv
    end
    # redirect_to root_path
  end

  def About
  end
end
