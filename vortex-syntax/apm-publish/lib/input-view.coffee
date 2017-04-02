{CompositeDisposable} = require 'atom'
{View, TextEditorView} = require 'atom-space-pen-views'

module.exports = class InputView extends View
  @content: ->
    @div =>
      @subview 'versionEditor', new TextEditorView(mini: true, placeholderText: '0.0.1')

  initialize: (@directory, @spawn) ->
    @disposables = new CompositeDisposable
    @currentPane = atom.workspace.getActivePane()
    @panel = atom.workspace.addModalPanel(item: this)
    @panel.show()

    @versionEditor.focus()
    @disposables.add atom.commands.add 'atom-text-editor', 'core:cancel': (event) => @destroy()
    @disposables.add atom.commands.add 'atom-text-editor', 'core:confirm': (event) => @finish()

  destroy: ->
    @panel.destroy()
    @disposables.dispose()
    @currentPane.activate()

  finish: ->
    @destroy()
    version = @versionEditor.getModel().getText()
    @spawn version, @directory if version.length > 0
