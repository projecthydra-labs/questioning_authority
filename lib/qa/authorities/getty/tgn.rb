# frozen_string_literal: true
module Qa::Authorities
  class Getty::TGN < Base
    include WebServiceBase

    def search(q)
      parse_authority_response(json(build_query_url(q)))
    end

    def build_query_url(q)
      query = ERB::Util.url_encode(sparql(untaint(q)))
      # Replace ampersands, otherwise the query will fail
      # Gsub hack to convert the encoded regex in the REPLACE into a form Getty understands
      "http://vocab.getty.edu/sparql.json?query=#{query.gsub('&', '%26').gsub(',[%5E,]+,[%5E,]+$', '%2C[^%2C]%2B%2C[^%2C]%2B%24')}&_implicit=false&implicit=true&_equivalent=false&_form=%2Fsparql"
    end

    # Use a regex to exclude the continent and 'world' from the query
    # If only one word is entered only search the name (not the parent string)
    # If more than one word is entered, one word must appear in the name, and all words in either parent or name
    def sparql(q) # rubocop:disable Metrics/MethodLength
      search = untaint(q)
      if search.include?(' ')
        clauses = search.split(' ').collect do |i|
          %((regex(?name, "#{i}", "i") || regex(?alt, "#{i}", "i")))
        end
        ex = "(#{clauses.join(' && ')})"
      else
        ex = %(regex(?name, "#{search}", "i"))
      end
      %(SELECT DISTINCT ?s ?name ?par {
        ?s a skos:Concept; luc:term "#{search}";
            skos:inScheme <http://vocab.getty.edu/tgn/> ;
            gvp:prefLabelGVP [skosxl:literalForm ?name] ;
                  gvp:parentString ?par .
        FILTER #{ex} .
      } ORDER BY ?name ASC(?par)).gsub(/[\s\n]+/, " ")
    end

    def untaint(q)
      q.gsub(/[^\w\s-]/, '')
    end

    def find(id)
      json(find_url(id))
    end

    def find_url(id)
      "http://vocab.getty.edu/download/json?uri=http://vocab.getty.edu/tgn/#{id}.json"
    end

    def request_options
      { accept: 'application/sparql-results+json' }
    end

    private

    # Reformats the data received from the service
    # Adds the parentString, minus the contintent and 'World' for disambiguation
    def parse_authority_response(response)
      response['results']['bindings'].map do |result|
        { 'id' => result['s']['value'], 'label' => result['name']['value'] + ' (' + result['par']['value'].gsub(/\,[^\,]+\,[^\,]+$/, '') + ')' }
      end
    rescue StandardError => e
      cause = response.fetch('error', {}).fetch('cause', 'UNKNOWN')
      cause = cause.presence || 'UNKNOWN'
      Rails.logger.warn "  ERROR fetching Getty response: #{e.message}; cause: #{cause}"
      {}
    end
  end
end
