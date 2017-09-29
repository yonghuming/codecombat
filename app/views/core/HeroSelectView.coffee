require('app/styles/core/hero-select-view.sass')
CocoView = require 'views/core/CocoView'
template = require 'templates/core/hero-select-view'
# Classroom = require 'models/Classroom'
# ThangTypes = require 'collections/ThangTypes'
State = require 'models/State'
# ThangType = require 'models/ThangType'
ThangTypeConstants = require 'lib/ThangTypeConstants'
User = require 'models/User'

module.exports = class HeroSelectView extends CocoView
  id: 'hero-select-view'
  template: template

  events:
    'click .hero-option': 'onClickHeroOption'

  initialize: (@options = {}) ->
    defaultHeroOriginal = ThangTypeConstants.heroes.captain
    currentHeroOriginal = me.get('heroConfig')?.thangType or defaultHeroOriginal

    @debouncedRender = _.debounce @render, 0

    @state = new State({
      currentHeroOriginal
      selectedHeroOriginal: currentHeroOriginal
    })

    # @heroes = new ThangTypes({}, { project: ['original', 'name', 'heroClass'] })
    # @supermodel.trackRequest @heroes.fetchHeroes()
    
    @supermodel.trackRequest api.thangTypes.getAll({ project: ['original', 'name', 'heroClass'] }).then (@heroes) =>
      @debouncedRender()

    @listenTo @state, 'all', -> @debouncedRender()
    # @listenTo @heroes, 'all', -> @debouncedRender()

  onClickHeroOption: (e) ->
    heroOriginal = $(e.currentTarget).data('hero-original')
    @state.set selectedHeroOriginal: heroOriginal
    @saveHeroSelection(heroOriginal)
    
  getHeroPortraitUrl: (hero) ->
    ThangTypeLib.getPortraitURL(hero)

  saveHeroSelection: (heroOriginal) ->
    me.set(heroConfig: {}) unless me.get('heroConfig')
    heroConfig = _.assign me.get('heroConfig'), { thangType: heroOriginal }
    me.set({ heroConfig })

    hero = _.find(@heroes, { original: heroOriginal })
    me.save().then =>
      event = 'Hero selected'
      event += if me.isStudent() then ' student' else ' teacher'
      event += ' create account' if @options.createAccount
      category = if me.isStudent() then 'Students' else 'Teachers'
      window.tracker?.trackEvent event, {category, heroOriginal}, []
      @trigger 'hero-select:success', {attributes: hero}
