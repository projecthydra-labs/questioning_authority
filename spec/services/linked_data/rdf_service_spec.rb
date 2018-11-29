require 'spec_helper'

RSpec.describe Qa::LinkedData::RdfService do
  describe '.graph' do
    context 'without language filter' do
      subject { described_class.graph(url) }
      let(:url) { 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage' }

      before do
        stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage')
          .to_return(status: 200, body: webmock_fixture('lod_oclc_all_query_3_results.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
      end

      it 'builds a graph with many statements' do
        expect(subject).to be_kind_of RDF::Graph
        expect(subject.statements.size).to be > 10
      end
    end

    context 'with language filter' do
      subject { described_class.graph(url, language) }

      let(:url) { 'http://authority.with.language/search?query=foo' }

      let(:en_dried_milk) { RDF::Literal.new("dried milk", language: :en) }
      let(:fr_dried_milk) { RDF::Literal.new("lait en poudre", language: :fr) }
      let(:de_dried_milk) { RDF::Literal.new("getrocknete Milch", language: :de) }

      let(:en_buttermilk) { RDF::Literal.new("buttermilk", language: :en) }
      let(:fr_buttermilk) { RDF::Literal.new("Babeurre", language: :fr) }
      let(:de_buttermilk) { RDF::Literal.new("Buttermilch", language: :de) }

      let(:en_condensed_milk) { RDF::Literal.new("condensed milk", language: :en) }
      let(:fr_condensed_milk) { RDF::Literal.new("lait condensé", language: :fr) }
      let(:de_condensed_milk) { RDF::Literal.new("Kondensmilch", language: :de) }

      before do
        stub_request(:get, 'http://authority.with.language/search?query=foo')
          .to_return(status: 200, body: webmock_fixture('lod_lang_search_enfrde.rdf.xml'), headers: { 'Content-Type' => 'application/rdf+xml' })
      end

      context 'and one language passed in as string' do
        let(:language) { "en" }

        it 'returns the graph with only the English subset of triples' do
          expect(subject.has_object?(en_dried_milk)).to be true
          expect(subject.has_object?(en_buttermilk)).to be true
          expect(subject.has_object?(en_condensed_milk)).to be true

          expect(subject.has_object?(fr_dried_milk)).to be false
          expect(subject.has_object?(fr_buttermilk)).to be false
          expect(subject.has_object?(fr_condensed_milk)).to be false

          expect(subject.has_object?(de_dried_milk)).to be false
          expect(subject.has_object?(de_buttermilk)).to be false
          expect(subject.has_object?(de_condensed_milk)).to be false
        end
      end

      context 'when one language passed in as symbol' do
        let(:language) { :fr }

        it 'returns the graph with only the French subset of triples' do
          expect(subject.has_object?(en_dried_milk)).to be false
          expect(subject.has_object?(en_buttermilk)).to be false
          expect(subject.has_object?(en_condensed_milk)).to be false

          expect(subject.has_object?(fr_dried_milk)).to be true
          expect(subject.has_object?(fr_buttermilk)).to be true
          expect(subject.has_object?(fr_condensed_milk)).to be true

          expect(subject.has_object?(de_dried_milk)).to be false
          expect(subject.has_object?(de_buttermilk)).to be false
          expect(subject.has_object?(de_condensed_milk)).to be false
        end
      end

      context 'when multiple languages passed in as strings in an array' do
        let(:language) { ["en", "fr"] }

        it 'returns the graph with English and French subset of triples' do
          expect(subject.has_object?(en_dried_milk)).to be true
          expect(subject.has_object?(en_buttermilk)).to be true
          expect(subject.has_object?(en_condensed_milk)).to be true

          expect(subject.has_object?(fr_dried_milk)).to be true
          expect(subject.has_object?(fr_buttermilk)).to be true
          expect(subject.has_object?(fr_condensed_milk)).to be true

          expect(subject.has_object?(de_dried_milk)).to be false
          expect(subject.has_object?(de_buttermilk)).to be false
          expect(subject.has_object?(de_condensed_milk)).to be false
        end
      end

      context 'when multiple languages passed in as symbols in an array' do
        let(:language) { [:en, :de] }

        it 'returns the graph with English and German subset of triples' do
          expect(subject.has_object?(en_dried_milk)).to be true
          expect(subject.has_object?(en_buttermilk)).to be true
          expect(subject.has_object?(en_condensed_milk)).to be true

          expect(subject.has_object?(fr_dried_milk)).to be false
          expect(subject.has_object?(fr_buttermilk)).to be false
          expect(subject.has_object?(fr_condensed_milk)).to be false

          expect(subject.has_object?(de_dried_milk)).to be true
          expect(subject.has_object?(de_buttermilk)).to be true
          expect(subject.has_object?(de_condensed_milk)).to be true
        end
      end
    end

    context 'when term is not found' do
      let(:url) { 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage' }

      before do
        stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage')
          .to_return(status: 404)
      end

      it 'raises error' do
        expect { described_class.graph(url) }.to raise_error(Qa::TermNotFound, "#{url} Not Found - Term may not exist at LOD Authority. (HTTPNotFound - 404)")
      end
    end

    context 'when service error' do
      subject { described_class.graph(url) }

      let(:url) { 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage' }
      let(:uri) { URI(url) }

      before do
        stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage')
          .to_return(status: 500)
      end

      it 'raises error' do
        expect { subject }.to raise_error(Qa::ServiceError, "#{uri.hostname} on port #{uri.port} is not responding.  Try again later. (HTTPServerError - 500)")
      end
    end

    context 'when service unavailable' do
      subject { described_class.graph(url) }

      let(:url) { 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage' }
      let(:uri) { URI(url) }

      before do
        stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage')
          .to_return(status: 503)
      end

      it 'raises error' do
        expect { subject }.to raise_error(Qa::ServiceUnavailable, "#{uri.hostname} on port #{uri.port} is not responding.  Try again later. (HTTPServiceUnavailable - 503)")
      end
    end

    context "when error isn't specifically handled" do
      subject { described_class.graph(url) }

      let(:url) { 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage' }
      let(:uri) { URI(url) }

      before do
        stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage')
          .to_return(status: 504)
      end

      it 'raises error' do
        expect { subject }.to raise_error(Qa::ServiceError, "Unknown error for #{uri.hostname} on port #{uri.port}.  Try again later. (Cause - <#{url}>: (504))")
      end
    end
  end

  describe '.filter_language' do
    it 'is tested by .graph method' do
      skip 'all test scenarios are covered by testing of .graph method using language parameter'
    end
  end

  describe '.filter_out_subject_blanknodes' do
    let(:url) { 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage' }
    let(:graph) { described_class.graph(url) }

    before do
      stub_request(:get, 'http://experimental.worldcat.org/fast/search?maximumRecords=3&query=cql.any%20all%20%22cornell%22&sortKeys=usage')
        .to_return(status: 200, body: webmock_fixture('lod_search_with_blanknode_subjects.nt'), headers: { 'Content-Type' => 'application/n-triples' })
    end

    it 'removes statements where the subject is a blanknode' do
      expect(graph.size).to be 12
      filtered_graph = described_class.filter_out_subject_blanknodes(graph)
      expect(filtered_graph.size).to be 9
    end
  end
end
