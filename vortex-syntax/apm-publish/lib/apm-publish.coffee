{BufferedProcess} = require 'atom'
notifier = require('atom-notify')('Apm Publish')
OutputView = require './output-view'
InputView = require './input-view'
RepoListView = require './repo-list-view'

getRepoForCurrentFile = ->
  new Promise (resolve, reject) ->
    project = atom.project
    path = atom.workspace.getActiveTextEditor()?.getPath()
    directory = project.getDirectories().filter((d) -> d.contains(path))[0]
    if directory?
      project.repositoryForDirectory(directory).then (repo) ->
        submodule = repo.repo.submoduleForPath(path)
        if submodule? then resolve(submodule) else resolve(repo)
      .catch (e) ->
        reject(e)
    else
      reject "no current file"

getRepoPath = ->
  new Promise (resolve, reject) ->
    getRepoForCurrentFile().then (repo) -> resolve(repo)
    .catch (e) ->
      repos = atom.project.getRepositories().filter (r) -> r?
      if repos.length is 0
        reject("No repos found")
      else if repos.length > 1
        resolve(new RepoListView(repos).promise)
      else
        resolve(repos[0])

module.exports =
  activate: ->
    atom.commands.add 'atom-workspace', 'apm-publish:version', => @showInput()
    atom.commands.add 'atom-workspace', 'apm-publish:major', => @publish 'major'
    atom.commands.add 'atom-workspace', 'apm-publish:minor', => @publish 'minor'
    atom.commands.add 'atom-workspace', 'apm-publish:patch', => @publish 'patch'

  publish: (version) ->
    getRepoPath()
    .then (repo) => @spawn version, repo.getWorkingDirectory()
    .catch (msg) -> notifier.addInfo "There's no project to publish"

  showInput: ->
    getRepoPath()
    .then (repo) => new InputView(repo.getWorkingDirectory(), @spawn)
    .catch (msg) -> notifier.addInfo "There's no project to publish"

  spawn: (version, cwd) ->
    message = notifier.addInfo "Publishing...", dismissable: true
    view = new OutputView
    new BufferedProcess
      command: atom.packages.getApmPath()
      args: ['publish', '--no-color', version]
      options:
        cwd: cwd
      stdout: (data) ->
        view.addLine data.toString()
      stderr: (data) ->
        view.addLine data.toString()
      exit: (code) ->
        message.dismiss()
        view.finish()
