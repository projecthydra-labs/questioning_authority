require 'spec_helper'

describe Qa::Authorities::LinkedData::Config do
  let(:full_config) { described_class.new(:LOD_FULL_CONFIG) }
  let(:min_config) { described_class.new(:LOD_MIN_CONFIG) }
  let(:term_only_config) { described_class.new(:LOD_TERM_ONLY_CONFIG) }

  describe '#search_config' do
    let(:full_search_config) do
      {
        'url' => 'http://localhost/test_default/search?subauth=__SEARCH_SUB_AUTH__&query=__QUERY__&param1=__SEARCH_REP_PARAM1__&param2=__SEARCH_REP_PARAM2__',
        'language' => ['en', 'fr', 'de'],
        'replacement_count' => 2,
        'replacement_1' => { 'param' => 'search_param1', 'pattern' => '__SEARCH_REP_PARAM1__', 'default' => 'delta' },
        'replacement_2' => { 'param' => 'search_param2', 'pattern' => '__SEARCH_REP_PARAM2__', 'default' => 'echo' },
        'results' => {
          'id_predicate' => 'http://purl.org/dc/terms/identifier',
          'label_predicate' => 'http://www.w3.org/2004/02/skos/core#prefLabel',
          'altlabel_predicate' => 'http://www.w3.org/2004/02/skos/core#altLabel',
          'sort_predicate' => 'http://www.w3.org/2004/02/skos/core#prefLabel'
        },
        'subauthorities' => {
          'replacement' => { 'pattern' => '__SEARCH_SUB_AUTH__', 'default' => 'search_sub1_name' },
          'search_sub1_key' => 'search_sub1_name',
          'search_sub2_key' => 'search_sub2_name', 'search_sub3_key' => 'search_sub3_name'
        }
      }
    end

    it 'returns nil if only term configuration is defined' do
      expect(term_only_config.search_config).to eq nil
    end
    it 'returns hash of search configuration' do
      expect(full_config.search_config).to eq full_search_config
    end
  end

  describe '#supports_search?' do
    it 'returns false if search is NOT configured' do
      expect(term_only_config.supports_search?).to eq false
    end
    it 'returns true if search is configured' do
      expect(full_config.supports_search?).to eq true
    end
  end

  describe '#search_url' do
    it 'returns nil if only term configuration is defined' do
      expect(term_only_config.search_url).to eq nil
    end
    it 'returns the search url from the configuration' do
      expected_url = 'http://localhost/test_default/search?subauth=__SEARCH_SUB_AUTH__&query=__QUERY__&param1=__SEARCH_REP_PARAM1__&param2=__SEARCH_REP_PARAM2__'
      expect(full_config.search_url).to eq expected_url
    end
  end

  describe '#search_language' do
    it 'returns nil if only term configuration is defined' do
      expect(term_only_config.search_language).to eq nil
    end
    it 'returns nil if language is not specified' do
      expect(min_config.search_language).to eq nil
    end
    it 'returns the preferred language for selecting literal values if configured for search' do
      expect(full_config.search_language).to eq [:en, :fr, :de]
    end
  end

  describe '#search_results_id_predicate' do
    it 'returns nil if only term configuration is defined' do
      expect(term_only_config.search_results_id_predicate).to eq nil
    end
    it 'returns the predicate that holds the ID in search results' do
      expect(full_config.search_results_id_predicate).to eq RDF::URI('http://purl.org/dc/terms/identifier')
    end
  end

  describe '#search_results_label_predicate' do
    it 'returns nil if only term configuration is defined' do
      expect(term_only_config.search_results_label_predicate).to eq nil
    end
    it 'returns the predicate that holds the label in search results' do
      expect(full_config.search_results_label_predicate).to eq RDF::URI('http://www.w3.org/2004/02/skos/core#prefLabel')
    end
  end

  describe '#search_results_altlabel_predicate' do
    it 'returns nil if only term configuration is defined' do
      expect(term_only_config.search_results_altlabel_predicate).to eq nil
    end
    it 'return nil if altlabel predicate is not defined' do
      expect(min_config.search_results_altlabel_predicate).to eq nil
    end
    it 'returns the predicate that holds the altlabel in search results' do
      expect(full_config.search_results_altlabel_predicate).to eq RDF::URI('http://www.w3.org/2004/02/skos/core#altLabel')
    end
  end

  describe '#search_results_sort_predicate' do
    it 'returns nil if only term configuration is defined' do
      expect(term_only_config.search_results_sort_predicate).to eq nil
    end
    it 'return nil if sort predicate is not defined' do
      expect(min_config.search_results_sort_predicate).to eq nil
    end
    it 'returns the predicate on which results should be sorted' do
      expect(full_config.search_results_sort_predicate).to eq RDF::URI('http://www.w3.org/2004/02/skos/core#prefLabel')
    end
  end

  describe '#search_replacements?' do
    it 'returns false if only term configuration is defined' do
      expect(term_only_config.search_replacements?).to eq false
    end
    it 'returns false if the configuration does NOT define replacements' do
      expect(min_config.search_replacements?).to eq false
    end
    it 'returns true if the configuration defines replacements' do
      expect(full_config.search_replacements?).to eq true
    end
  end

  describe '#search_replacement_count' do
    it 'returns 0 if only term configuration is defined' do
      expect(term_only_config.search_replacement_count).to eq 0
    end
    it 'returns 0 if replacement_count is NOT defined' do
      expect(min_config.search_replacement_count).to eq 0
    end
    it 'returns the number of replacements if defined' do
      expect(full_config.search_replacement_count).to eq 2
    end
  end

  describe '#search_replacements' do
    it 'returns empty hash if only term configuration is defined' do
      empty_hash = {}
      expect(term_only_config.search_replacements).to eq empty_hash
    end
    it 'returns empty hash if no replacement patterns are defined' do
      empty_hash = {}
      expect(min_config.search_replacements).to eq empty_hash
    end
    it 'returns hash of all replacement patterns' do
      expected_hash = {
        'search_param1' => { pattern: '__SEARCH_REP_PARAM1__', default: 'delta' },
        'search_param2' => { pattern: '__SEARCH_REP_PARAM2__', default: 'echo' }
      }
      expect(full_config.search_replacements).to eq expected_hash
    end
  end

  describe '#search_subauthorities?' do
    it 'returns false if only term configuration is defined' do
      expect(term_only_config.search_subauthorities?).to eq false
    end
    it 'returns false if the configuration does NOT define subauthorities' do
      expect(min_config.search_subauthorities?).to eq false
    end
    it 'returns true if the configuration defines subauthorities' do
      expect(full_config.search_subauthorities?).to eq true
    end
  end

  describe '#search_subauthority?' do
    it 'returns false if only term configuration is defined' do
      expect(term_only_config.search_subauthority?('fake_subauth')).to eq false
    end
    it 'returns false if there are no subauthorities configured' do
      expect(min_config.search_subauthority?('fake_subauth')).to eq false
    end
    it 'returns false if the requested subauthority is NOT configured' do
      expect(full_config.search_subauthority?('fake_subauth')).to eq false
    end
    it 'returns true if the requested subauthority is configured' do
      expect(full_config.search_subauthority?('search_sub2_key')).to eq true
    end
  end

  describe '#search_subauthority_count' do
    it 'returns 0 if only term configuration is defined' do
      expect(term_only_config.search_subauthority_count).to eq 0
    end
    it 'returns 0 if the configuration does NOT define subauthorities' do
      expect(min_config.search_subauthority_count).to eq 0
    end
    it 'returns the number of subauthorities if defined' do
      expect(full_config.search_subauthority_count).to eq 3
    end
  end

  describe '#search_subauthorities' do
    it 'returns empty hash if only term configuration is defined' do
      empty_hash = {}
      expect(term_only_config.search_subauthorities).to eq empty_hash
    end
    it 'returns empty hash if no subauthorities are defined' do
      empty_hash = {}
      expect(min_config.search_subauthorities).to eq empty_hash
    end
    it 'returns hash of all subauthority key-value patterns defined' do
      expected_hash = {
        'search_sub1_key' => 'search_sub1_name',
        'search_sub2_key' => 'search_sub2_name',
        'search_sub3_key' => 'search_sub3_name'
      }
      expect(full_config.search_subauthorities).to eq expected_hash
    end
  end

  describe '#search_subauthority_replacement_pattern' do
    it 'returns empty hash if only term configuration is defined' do
      empty_hash = {}
      expect(term_only_config.search_subauthority_replacement_pattern).to eq empty_hash
    end
    it 'returns empty hash if no subauthorities are defined' do
      empty_hash = {}
      expect(min_config.search_subauthority_replacement_pattern).to eq empty_hash
    end
    it 'returns hash replacement pattern for subauthority and the default value' do
      expected_hash = { pattern: '__SEARCH_SUB_AUTH__', default: 'search_sub1_name' }
      expect(full_config.search_subauthority_replacement_pattern).to eq expected_hash
    end
  end

  describe '#search_url_with_replacements' do
    it 'returns nil if only term configuration is defined' do
      expect(term_only_config.search_url_with_replacements('Smith')).to eq nil
    end
    it 'returns the url with query substitution applied' do
      expected_url = 'http://localhost/test_default/search?subauth=search_sub1_name&query=Smith&param1=delta&param2=echo'
      expect(full_config.search_url_with_replacements('Smith')).to eq expected_url
    end
    it 'returns the url with default subauthority when NOT specified' do
      expected_url = 'http://localhost/test_default/search?subauth=search_sub1_name&query=Smith&param1=delta&param2=echo'
      expect(full_config.search_url_with_replacements('Smith')).to eq expected_url
    end
    it 'returns the url with subauthority substitution when specified' do
      expected_url = 'http://localhost/test_default/search?subauth=search_sub3_name&query=Smith&param1=delta&param2=echo'
      expect(full_config.search_url_with_replacements('Smith', 'search_sub3_key')).to eq expected_url
    end
    it 'returns the url with default values when replacements are NOT specified' do
      expected_url = 'http://localhost/test_default/search?subauth=search_sub1_name&query=Smith&param1=delta&param2=echo'
      expect(full_config.search_url_with_replacements('Smith')).to eq expected_url
    end
    it 'returns the url with replacement substitution values when replacements are specified' do
      expected_url = 'http://localhost/test_default/search?subauth=search_sub1_name&query=Smith&param1=golf&param2=hotel'
      expect(full_config.search_url_with_replacements('Smith', nil, 'search_param1' => 'golf', 'search_param2' => 'hotel')).to eq expected_url
    end

    context 'when subauthorities are not defined' do
      it 'returns the url with query substitution applied' do
        expected_url = 'http://localhost/test_default/search?query=Smith'
        expect(min_config.search_url_with_replacements('Smith')).to eq expected_url
      end
      it 'and subauth param is included returns the url with query substitution applied ignoring the subauth' do
        expected_url = 'http://localhost/test_default/search?query=Smith'
        expect(min_config.search_url_with_replacements('Smith', 'fake_subauth_key')).to eq expected_url
      end
    end

    context 'when replacements are not defined' do
      it 'returns the url with query substitution applied' do
        expected_url = 'http://localhost/test_default/search?query=Smith'
        expect(min_config.search_url_with_replacements('Smith')).to eq expected_url
      end
      it 'and replacements param is included returns the url with query substitution applied ignoring the replacements' do
        expected_url = 'http://localhost/test_default/search?query=Smith'
        expect(min_config.search_url_with_replacements('Smith', nil, 'fake_replacement_key' => 'fake_value')).to eq expected_url
      end
    end
  end
end
