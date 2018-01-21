moment.locale 'ja'
timeFormat = 'LL LTS'

serverErrorHandler = (xhr, msg, ext) ->
    UIkit.notification
        message: "Server #{msg}: status = #{xhr.status}"
        status: 'danger'
        pos: 'bottom-center'
        timeout: 2000

serverStatusHandler = (msg) ->
    return if msg is 'ok'
    UIkit.notification
        message: "Server status: #{msg}"
        status: 'warning'
        pos: 'bottom-center'
        timeout: 500

clockVue = new Vue
    el: '#menuClock'
    data:
        time: moment().format timeFormat
    mounted: ()->
        setInterval @update
        , 1000
    methods:
        update: ()->
            @time = moment().format timeFormat

todoVue = new Vue
    el: '#matrix'
    data:
        next_id: 9
        items00: [
            {'id': 1, 'text': 'test01', 'folder' : '', 'url': ''}
            {'id': 2, 'text': 'test02', 'folder' : '', 'url': ''}
        ]
        items01: [
            {'id': 3, 'text': 'test03', 'folder' : '', 'url': ''}
            {'id': 4, 'text': 'test04', 'folder' : '', 'url': ''}
        ]
        items02: [
            {'id': 5, 'text': 'test05', 'folder' : '', 'url': ''}
            {'id': 6, 'text': 'test06', 'folder' : '', 'url': ''}
        ]
        items03: [
            {'id': 7, 'text': 'test07', 'folder' : '', 'url': ''}
            {'id': 8, 'text': 'test08', 'folder' : '', 'url': ''}
        ]
    methods:
        stoped: (e)->
            console.log 'stop at ' + moment().format timeFormat
            console.log e

folderListVue = new Vue
    el: '#folderList'
    data:
        folderList00: []
        folderList01: []
        folderList02: []
        current00: ''
        current01: ''
        current02: ''
        sethover: {}
    created: ()->
        @initialize('/')
    methods:
        open: (e)->
            target_folder = e.target.innerText
            console.log target_folder
            $.ajax
                url: '/open'
                method: 'POST'
                contentType: 'application/json'
                data: JSON.stringify {'path_name': target_folder}
                success: (e) ->
                    console.log 'opened.'
                    serverStatusHandler(e.status)
                error: (xhr, msg, ext) ->
                    serverErrorHandler(xhr, msg, ext)
        mouseenter: (e)->
            #console.log("mouse enter")
            folderName = _.trim e.target.innerText
            index = _.toInteger _.trim(e.target.firstChild.innerText)
            parentFolder = _.trim e.target.parentNode.parentNode.firstChild.innerText
            targetFolder = parentFolder + '/' + folderName
            targetFolder = _.replace targetFolder, '//', '/'
            list_name = _.trim(e.target.attributes.name.value)[-2..]
            folderList = @folderList00
            folderList = @folderList01 if list_name is '01'
            folderList = @folderList02 if list_name is '02'
            if not folderList[index].isfile
                console.log(index + ", " + targetFolder)
                console.log(e)
                @sethover = setTimeout ()->
                    e.target.classList.add('uk-animation-shake')
                    $.ajax
                        url: "/size"
                        method: 'POST'
                        contentType: 'application/json'
                        data: JSON.stringify {'path_name': targetFolder, 'list_name': list_name, 'index': index}
                        success: (e) ->
                            console.log(e)
                            serverStatusHandler(e.size)
                            folderListVue.setFolderListSize(e.list_name, e.index, e.size)
                        error: (xhr, msg, ext) ->
                            serverErrorHandler(xhr, msg, ext)
                , 3000
        mouseleave: (e)->
            # console.log("mouse leave")
            e.target.classList = []
            clearTimeout @sethover
        clicked: (e)->
            console.log 'clicked.'
            index = _.toInteger _.trim(e.target.parentElement.childNodes[0].innerText)
            console.log 'index: ' + index
            if index < 0
                @initialize(@current00 + '/..')
                return
            return if not e.target.attributes.name
            list_name = _.trim(e.target.attributes.name.value)[-2..]
            folderList = @folderList00
            folderList = @folderList01 if list_name is '01'
            folderList = @folderList02 if list_name is '02'
            if not folderList[index].isfile  # フォルダをクリック
                if list_name is '00'
                    target_folder = @current00 + '/' + folderList[index].name
                    console.log target_folder
                    $.ajax
                        url: "/find"
                        method: 'POST'
                        contentType: 'application/json'
                        data: JSON.stringify {'path_name': target_folder}
                        success: (e) ->
                            folderListVue.update01 e.current, e.contents
                            serverStatusHandler(e.status)
                        error: (xhr, msg, ext) ->
                            serverErrorHandler(xhr, msg, ext)
                else if list_name is '01'
                    target_folder = @current01 + '/' + folderList[index].name
                    console.log target_folder
                    $.ajax
                        url: "/find"
                        method: 'POST'
                        contentType: 'application/json'
                        data: JSON.stringify {'path_name': target_folder}
                        success: (e) ->
                            folderListVue.update02 e.current, e.contents
                            serverStatusHandler(e.status)
                        error: (xhr, msg, ext) ->
                            serverErrorHandler(xhr, msg, ext)
                else
                    target_folder = @current02 + '/' + folderList[index].name
                    console.log target_folder
                    $.ajax
                        url: "/find"
                        method: 'POST'
                        contentType: 'application/json'
                        data: JSON.stringify {'path_name': target_folder}
                        success: (e) ->
                            folderListVue.update02_and_shift e.current, e.contents
                            serverStatusHandler(e.status)
                        error: (xhr, msg, ext) ->
                            serverErrorHandler(xhr, msg, ext)
            else  # ファイルをクリック
                console.log 'file: ' + folderList[index].name
        update00: (current, folder)->
            @current00 = _.replace current, '//', '/'
            @folderList00 = folder
        update01: (current, folder)->
            @current01 = _.replace current, '//', '/'
            @current02 = ''
            @folderList01 = folder
            @folderList02 = []
        update02: (current, folder)->
            @current02 = _.replace current, '//', '/'
            @folderList02 = folder
        update02_and_shift: (current, folder)->
            @current00 = @current01
            @current01 = @current02
            @current02 = _.replace current, '//', '/'
            @folderList00 = @folderList01
            @folderList01 = @folderList02
            @folderList02 = folder
        update: (current, folders)->
            @current00 = _.replace current, '//', '/'
            @current01 = ''
            @current02 = ''
            @folderList00 = folders[0]
            @folderList01 = folders[1]
            @folderList02 = folders[2]
        setFolderListSize: (list_name, index, size)->
            folderList = @folderList00
            if list_name is '01'
                folderList = @folderList01
            if list_name is '02'
                folderList = @folderList02
            folderList[index].size = size
        initialize: (current)->
            $.ajax
                url: "/find"
                method: 'POST'
                contentType: 'application/json'
                data: JSON.stringify {'path_name':current}
                success: (e) ->
                    folderListVue.update e.current, [e.contents, [], []]
                    serverStatusHandler(e.status)
                error: (xhr, msg, ext) ->
                    serverErrorHandler(xhr, msg, ext)
    

console.log moment().format(timeFormat) + " started."

# -------------------------------------------------------
$(() ->
    $('body').removeClass 'uk-invisible'
    $('#iteminput').focus()
)
