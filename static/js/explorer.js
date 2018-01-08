// Generated by CoffeeScript 2.1.1
(function() {
  var clockVue, folderListVue, serverErrorHandler, timeFormat, todoVue;

  moment.locale('ja');

  timeFormat = 'LL LTS';

  serverErrorHandler = function(xhr, msg, ext) {
    return UIkit.notification({
      message: `Server ${msg}: status = ${xhr.status}`,
      status: 'danger',
      pos: 'bottom-center',
      timeout: 2000
    });
  };

  clockVue = new Vue({
    el: '#menuClock',
    data: {
      time: moment().format(timeFormat)
    },
    mounted: function() {
      return setInterval(this.update, 1000);
    },
    methods: {
      update: function() {
        return this.time = moment().format(timeFormat);
      }
    }
  });

  todoVue = new Vue({
    el: '#matrix',
    data: {
      items00: [
        {
          'text': 'test01',
          'folder': 'folder01'
        },
        {
          'text': 'test02',
          'folder': 'folder02'
        }
      ],
      items01: [
        {
          'text': 'test03',
          'folder': 'folder03'
        },
        {
          'text': 'test04',
          'folder': 'folder04'
        }
      ],
      items02: [
        {
          'text': 'test05',
          'folder': 'folder05'
        },
        {
          'text': 'test06',
          'folder': 'folder06'
        }
      ],
      items03: [
        {
          'text': 'test07',
          'folder': 'folder07'
        },
        {
          'text': 'test08',
          'folder': 'folder08'
        }
      ]
    },
    methods: {
      stoped: function(e) {
        console.log('stop at ' + moment().format(timeFormat));
        return console.log(e);
      }
    }
  });

  folderListVue = new Vue({
    el: '#folderList',
    data: {
      folderList00: [],
      folderList01: [],
      folderList02: [],
      current00: '',
      current01: '',
      current02: ''
    },
    created: function() {
      return this.initialize('/');
    },
    methods: {
      open: function(e) {
        var target_folder;
        target_folder = e.target.innerText;
        console.log(target_folder);
        return $.ajax({
          url: '/open',
          method: 'POST',
          contentType: 'application/json',
          data: JSON.stringify({
            'path_name': target_folder
          }),
          success: function(e) {
            return console.log('opened.');
          },
          error: function(xhr, msg, ext) {
            return serverErrorHandler(xhr, msg, ext);
          }
        });
      },
      clicked: function(e) {
        var folderList, index, list_name, target_folder;
        console.log('clicked.');
        index = _.toInteger(_.trim(e.target.parentElement.childNodes[0].innerText));
        console.log('index: ' + index);
        if (index < 0) {
          this.initialize(this.current00 + '/..');
          return;
        }
        if (!e.target.attributes.name) {
          return;
        }
        list_name = _.trim(e.target.attributes.name.value).slice(-2);
        folderList = this.folderList00;
        if (list_name === '01') {
          folderList = this.folderList01;
        }
        if (list_name === '02') {
          folderList = this.folderList02;
        }
        if (!folderList[index].isfile) { // フォルダをクリック
          if (list_name === '00') {
            target_folder = this.current00 + '/' + folderList[index].name;
            console.log(target_folder);
            return $.ajax({
              url: "/find",
              method: 'POST',
              contentType: 'application/json',
              data: JSON.stringify({
                'path_name': target_folder
              }),
              success: function(e) {
                return folderListVue.update01(e.current, e.contents);
              },
              error: function(xhr, msg, ext) {
                return serverErrorHandler(xhr, msg, ext);
              }
            });
          } else if (list_name === '01') {
            target_folder = this.current01 + '/' + folderList[index].name;
            console.log(target_folder);
            return $.ajax({
              url: "/find",
              method: 'POST',
              contentType: 'application/json',
              data: JSON.stringify({
                'path_name': target_folder
              }),
              success: function(e) {
                return folderListVue.update02(e.current, e.contents);
              },
              error: function(xhr, msg, ext) {
                return serverErrorHandler(xhr, msg, ext);
              }
            });
          } else {
            target_folder = this.current02 + '/' + folderList[index].name;
            console.log(target_folder);
            return $.ajax({
              url: "/find",
              method: 'POST',
              contentType: 'application/json',
              data: JSON.stringify({
                'path_name': target_folder
              }),
              success: function(e) {
                return folderListVue.update02_and_shift(e.current, e.contents);
              },
              error: function(xhr, msg, ext) {
                return serverErrorHandler(xhr, msg, ext); // ファイルをクリック
              }
            });
          }
        } else {
          return console.log('file: ' + folderList[index].name);
        }
      },
      update00: function(current, folder) {
        this.current00 = _.replace(current, '//', '/');
        return this.folderList00 = folder;
      },
      update01: function(current, folder) {
        this.current01 = _.replace(current, '//', '/');
        this.current02 = '';
        this.folderList01 = folder;
        return this.folderList02 = [];
      },
      update02: function(current, folder) {
        this.current02 = _.replace(current, '//', '/');
        return this.folderList02 = folder;
      },
      update02_and_shift: function(current, folder) {
        this.current00 = this.current01;
        this.current01 = this.current02;
        this.current02 = _.replace(current, '//', '/');
        this.folderList00 = this.folderList01;
        this.folderList01 = this.folderList02;
        return this.folderList02 = folder;
      },
      update: function(current, folders) {
        this.current00 = _.replace(current, '//', '/');
        this.current01 = '';
        this.current02 = '';
        this.folderList00 = folders[0];
        this.folderList01 = folders[1];
        return this.folderList02 = folders[2];
      },
      initialize: function(current) {
        return $.ajax({
          url: "/find",
          method: 'POST',
          contentType: 'application/json',
          data: JSON.stringify({
            'path_name': current
          }),
          success: function(e) {
            return folderListVue.update(e.current, [e.contents, [], []]);
          },
          error: function(xhr, msg, ext) {
            return serverErrorHandler(xhr, msg, ext);
          }
        });
      }
    }
  });

  console.log(moment().format(timeFormat) + " started.");

  // -------------------------------------------------------
  $(function() {
    $('body').removeClass('uk-invisible');
    return $('#iteminput').focus();
  });

}).call(this);

//# sourceMappingURL=explorer.js.map
