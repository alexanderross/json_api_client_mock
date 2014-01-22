require 'test_helper'

class JsonApiClientMockTest < MiniTest::Unit::TestCase

  def teardown
    JsonApiClient::Resource.clear_test_results
    super
  end

  def test_conditionless_mocking
    BarResource.set_test_results([{foo: 'bar', qwer: 'asdf'}])
    results = BarResource.all

    assert_equal(JsonApiClient::ResultSet, results.class)
    assert_equal(1, results.length)

    first = results.first
    assert_equal(BarResource, first.class)
    assert_equal('bar', first.foo)
    assert_equal('asdf', first.qwer)

    conditioned_results = BarResource.where(something: 'else').all
    assert_equal(JsonApiClient::ResultSet, results.class)
    assert_equal(1, conditioned_results.length)

    first = conditioned_results.first
    assert_equal(BarResource, first.class)
    assert_equal('bar', first.foo)
    assert_equal('asdf', first.qwer)
  end

  def test_missing_mock
    assert_raises(JsonApiClientMock::MissingMock) do
      BarResource.all
    end
  end

  def test_conditional_mocking
    BarResource.set_test_results([{foo: 'bar', qwer: 'asdf'}], {foo: 'bar'})
    assert_raises(JsonApiClientMock::MissingMock) do
      BarResource.all
    end

    results = BarResource.where(foo: 'bar').all
    assert_equal(1, results.length)

    first = results.first
    assert_equal(BarResource, first.class)
    assert_equal('bar', first.foo)
    assert_equal('asdf', first.qwer)
  end

  def test_conditional_mocking_param_order
    BarResource.set_test_results([{foo: 'bar', qwer: 'asdf'}], {foo: 'bar', qwer: 'asdf'})

    results = BarResource.where(foo: 'bar', qwer: 'asdf').all
    assert_equal(1, results.length)

    results = BarResource.where(qwer: 'asdf', foo: 'bar').all
    assert_equal(1, results.length)
  end

  def test_mocks_are_stored_by_class
    BarResource.set_test_results([{foo: 'bar', qwer: 'asdf'}])
    assert_raises(JsonApiClientMock::MissingMock) do
      FooResource.all
    end
  end

  def test_inherited_mocking
    BarResource.set_test_results([{foo: 'bar', qwer: 'asdf'}])
    assert_raises(JsonApiClientMock::MissingMock) do
      BarExtendedResource.all
    end
  end

end
