angular
  .module 'sbBlogData', ['sbConstants']
  .service 'sbBlogData', ($http, $q, CONTENT_ROOT, DESCRIPTOR_FILE_NAME) ->
    self = this

    self.data = undefined
    self.loadingPromise = undefined
    self.load = ()->
      if !loadingPromise
        loadingPromise = $http
        .get self.path [CONTENT_ROOT, DESCRIPTOR_FILE_NAME]
        .then (raw)->
          self.data = self.preProcessData(raw.data);
      return loadingPromise

    self.preProcessData = (raw)->
      self.extendPosts raw
      self.loadPostsInTree raw.tree, raw
      return raw

    self.extendPosts = (raw) ->
      _.each raw.posts, (post)->
        post.image = ((fileName)->
          self.getImagePath(this, fileName)).bind(post);
        post.url = self.getPostUrl post
        post.date = (new Date(post.date)).getTime();
      return raw

    self.loadPostsInTree = (root, data) ->
      _.each root, (value, key)->
        if _.isNumber value
          root[key] = data.posts[value];
        else
          self.loadPostsInTree value, data


    # Utils :
    self.path = (arr)->arr.join '/'
    self.postPath = (post, fileName)->self.path [CONTENT_ROOT].concat(post.directory, fileName)

    self.getPostUrl = (post)-> self.postPath post, post.postFileName + '.html'
    self.getImagePath = (post, fileName) -> self.postPath post, fileName
    self.getRoot = ( root, path ) ->
      path = path.concat()
      if path.length == 0
        return root
      if path.length == 1
        return root[path[0]]
      else
        return this.getRoot(root[path.shift()], path)

    return this