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
        items00: [
            {'text': 'test01', 'folder' : 'folder01'}
            {'text': 'test02', 'folder' : 'folder02'}
        ]
        items01: [
            {'text': 'test03', 'folder' : 'folder03'}
            {'text': 'test04', 'folder' : 'folder04'}
        ]
        items02: [
            {'text': 'test05', 'folder' : 'folder05'}
            {'text': 'test06', 'folder' : 'folder06'}
        ]
        items03: [
            {'text': 'test07', 'folder' : 'folder07'}
            {'text': 'test08', 'folder' : 'folder08'}
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
