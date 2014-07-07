"use strict"
module.exports = (grunt) ->
  
  # Project configuration.
  grunt.initConfig
    
    # Metadata.
    pkg: grunt.file.readJSON("package.json")
    banner: "/*!\n * <%= pkg.title || pkg.name %> - v<%= pkg.version %> - " +
            "<%= grunt.template.today(\"yyyy-mm-dd\") %>\n" +
            "<%= pkg.homepage ? \" * \" + pkg.homepage + \"\\n\" : \"\" %>" +
            " * Copyright (c) <%= grunt.template.today(\"yyyy\") %> <%= pkg.author.name %>;" +
            " Licensed <%= _.pluck(pkg.licenses, \"type\").join(\", \") %>\n */\n"
    
    # Task configuration.
    clean:
      files: ["dist"]

    concat:
      options:
        banner: "<%= banner %>"
        stripBanners: true

      dist:
        src: ["build/before.js", "build/dataMatcher.js", "build/<%= pkg.name %>.js"]
        dest: "dist/jquery-<%= pkg.name %>.<%= pkg.version %>.js"

    uglify:
      options:
        banner: "<%= banner %>"
        sourceMap: true

      dist:
        src: "<%= concat.dist.dest %>"
        dest: "dist/jquery-<%= pkg.name %>.<%= pkg.version %>.min.js"

    qunit:
      files: ["test/**/*Test.html"]

    jshint:
      src:
        options:
          jshintrc: "src/.jshintrc"

        src: ["build/*.js"]

      test:
        options:
          jshintrc: "test/.jshintrc"

        src: ["build/test/*.js"]

    coffee:
      app:
        expand: true
        cwd: 'src'
        src: ['**/*.coffee']
        dest: 'build'
        ext: '.js'

      test:
        expand: true
        cwd: 'test'
        src: ['**/*.coffee']
        dest: 'build/test'
        ext: '.js'

    watch:
      app:
        files: '**/*.coffee'
        tasks: ['coffee']

      gruntfile:
        files: "<%= jshint.gruntfile.src %>"
        tasks: ["jshint:gruntfile"]

      src:
        files: "<%= jshint.src.src %>"
        tasks: [
          "jshint:src"
          "qunit"
        ]

      test:
        files: "<%= jshint.test.src %>"
        tasks: [
          "jshint:test"
          "qunit"
        ]

  
  # These plugins provide necessary tasks.
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-qunit"
  grunt.loadNpmTasks "grunt-contrib-jshint"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  
  # Default task.
  grunt.registerTask "default", [
    "coffee"
    "jshint"
    "qunit"
    "clean"
    "concat"
    "uglify"
  ]

  grunt.registerTask "test", [
    "coffee"
    "jshint"
    "qunit"
  ]
