<service_header>
    <div id="header">
        <div class="container">
            <a href="/">
                <h1><img src="/images/aoeblue_90_370.png" width="185" height="45"
                         alt="AOE:All Of gene Expression"/></h1></a>
            <div id="switch_lang">

                <a href="/en"><button if={!lan_en} class="en">English</button></a>
                <a href="../"><button if={lan_en} class="ja">日本語</button></a>
            </div>
            <div class="search">
                <form action="">
                    <input type="text" size="30" name="fulltext" id="fulltext" value="" placeholder="Enter keyword. e.g. hypoxia"/>
                    <input if={!lan_en} type="button" class="btn" value="検索" id="fulltext_btn"/>
                    <input if={lan_en} type="button" class="btn" value="Search" id="fulltext_btn"/>
                </form>
            </div>
            <div id="menu">
                <a if={!lan_en} href="/" id="menu1" class="menu1">登録データランキング</a>
                <a if={!lan_en} href="/experiment" id="menu2" class="menu2">データリスト</a>
                <a if={!lan_en} href="https://doi.org/10.7875/togotv.2018.128" id="menu3">使い方</a>
                <a if={!lan_en} href="https://github.com/dbcls/AOE/blob/master/API_documentation.md" id="menu4">API</a>


                <a if={lan_en} href="/en" id="menu1" class="menu1">Ranking</a>
                <a if={lan_en} href="/en/experiment" id="menu2" class="menu2">Data List</a>
                <a if={lan_en} href="https://doi.org/10.7875/togotv.2018.146" id="menu3" class="menu3" class="menu4">How to use</a>
                <a if={lan_en} href="https://github.com/dbcls/AOE/blob/master/API_documentation.md" id="menu4" class="menu4">API</a>
            </div>
        </div>
    </div>

    <script>
        var self = this;
        this.on("mount", function () {
            // for IE
            if (!String.prototype.startsWith) {
                String.prototype.startsWith = function(searchString, position){
                  position = position || 0;
                  return this.substr(position, searchString.length) === searchString;
              };
            }

            var path = location.pathname;
            //
            self.lan_en = path.startsWith('/en') ? true : false;
            var f = {};

            self.update()
            f['/'] = function () {
                // #menuのスタイル変更
                $("div#menu a").removeClass();
                $("a#menu1").addClass("selected");

                // #fulltextに入力した検索 > mychart.js
                $(".search .btn").mychart();

            };
            f['/experiment'] = function () {
                // #menuのスタイル変更
                $("div#menu a").removeClass();
                $("a#menu2").addClass("selected");

                // #fulltextに入力する検索の挙動 > /experimentにfulltext=オプションをつけてリダイレクト
                $("#fulltext_btn").click(function () {
                    var text_val = document.getElementById('fulltext').value;
                    qs = path + '?fulltext=' + text_val;
                    location.href = qs;
                });

            };
            f['/en/experiment'] = f['/experiment'];
            f['/en'] = f['/'];

            f[path]();


        });

        change_lang(){
            var lang = location.pathname;
            self.lan_en = lang == "#en" ? true : false;
            self.update();
        }

    </script>

</service_header>