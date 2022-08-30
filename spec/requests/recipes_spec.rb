require 'rails_helper'

RSpec.describe 'Recipes', type: :request do
  before(:all) do
    @user = User.create!(name: 'Test User', email: 'test@email.com', password: 'password')
    @user2 = User.create!(name: 'Test User 2', email: 'test2@email.com', password: 'password')
    @first = Recipe.create!(name: 'Test Recipe', description: 'Test Description', public: 0, cooking_time: 60,
                            preparation_time: 60, user: @user)
    Recipe.create!(name: 'Test Recipe 2', description: 'Test Description', public: 0, cooking_time: 60,
                   preparation_time: 60, user: @user)
    Recipe.create!(name: 'Test Recipe 3', description: 'Test Description', public: 0, cooking_time: 60,
                   preparation_time: 60, user: @user)
    Recipe.create!(name: 'Test Recipe 4', description: 'Test Description', public: 0, cooking_time: 60,
                   preparation_time: 60, user: @user2)
  end

  describe 'GET /recipes' do
    it 'returns http success' do
      sign_in @user
      get '/recipes'
      expect(response).to have_http_status(:success)
    end

    it 'renders the index template' do
      sign_in @user
      get '/recipes'

      expect(response).to render_template('index')
    end

    it 'should display all recipes created by the current user' do
      sign_in @user
      get '/recipes'

      expect(response.body).to include('Test Recipe')
      expect(response.body).to include('Test Recipe 2')
      expect(response.body).to include('Test Recipe 3')
      expect(response.body).to_not include('Test Recipe 4')
    end
  end

  describe 'GET /recipes/:id' do
    it 'returns http success' do
      sign_in @user
      get recipe_path(Recipe.first)

      expect(response).to have_http_status(:success)
    end

    it 'renders the show template' do
      sign_in @user
      get recipe_path(Recipe.first)

      expect(response).to render_template('show')
    end

    it 'should display the recipe details' do
      sign_in @user
      get recipe_path(Recipe.first)

      expect(response.body).to include('Test Recipe')
      expect(response.body).to include('Test Description')
      expect(response.body).to include('60')
      expect(response.body).to include('60')
    end
  end

  describe 'DELETE /recipes/:id' do
    it 'should raises a AccessDenied error when the user hasn\'t signed in' do
      expect { delete recipe_path(@first) }.to raise_error(CanCan::AccessDenied)

      expect(Recipe.exists?(@first.id)).to be(true)
    end

    it 'should raises a AccessDenied error when the user is not the owner of the recipe' do
      sign_in @user
      expect { delete recipe_path(Recipe.last) }.to raise_error(CanCan::AccessDenied)

      expect(Recipe.last.destroyed?).to be(false)
    end

    it 'should delete the recipe when the user is the owner of the recipe and redirect to te recipes_path' do
      sign_in @user
      delete recipe_path(@first)
      expect(response).to redirect_to(recipes_path)
      expect(Recipe.exists?(@first.id)).to be(false)
    end
  end
end
