# 2학기 방학 프로젝트 (2020.01 ~ 2020.02)

미티어를 이용해 웹사이트 생성 프로젝트

## 주제

meteor를 통해 웹사이트의 기능을 공부함과 개인의 사이트를 구현

## 기획배경

개인별 데이터를 다루기 위해 개인의 정보인 일기나 일정을 관리하는 웹사이트를 기획

## 팀원

[박채희](https://github.com/ChaeheePark)  
구대홍  
[이환수](https://github.com/Lee-hwansoo)

## 사용프로그램

**vscode** : 코드 에디터

**mongoDB** : 로컬호스트 데이터베이스 관리

## 기능

**login** : 개인별 사이트 구현

**data input/output** : mongodb를 통해 웹사이트 구현

**file input** : 당일의 기분을 표현하는 노래 출력

## 웹 사이트 모습

![메인 페이지](https://user-images.githubusercontent.com/60167644/127848064-903b429c-dea5-406b-9473-dde34d59cc6a.png)

![회원가입](https://user-images.githubusercontent.com/60167644/127848172-bcfa36de-7b5f-4a48-b96f-d21799ccea90.png)

![로그인 된 페이지(일정 페이지)](https://user-images.githubusercontent.com/60167644/127848188-6b19ffd2-e198-466d-86af-1244eff8fef2.png)

![ex)일정작성](https://user-images.githubusercontent.com/60167644/127848202-8a254d6f-5fb4-46ed-a61e-8e73372cc2f8.png)

![ex)일정 작성후 모습](https://user-images.githubusercontent.com/60167644/127848219-b14c16a0-a4e3-41ad-9df4-15c8235eb505.png)

![일기 메인페이지](https://user-images.githubusercontent.com/60167644/127848227-e5af2379-9d0d-4b61-afea-d56f1f2957b3.png)

![일기 작성](https://user-images.githubusercontent.com/60167644/127848240-14639ddf-b4ad-472d-a163-04b100a6c3e3.png)

![가계부 작성1](https://user-images.githubusercontent.com/60167644/127848256-1e0aeb23-3639-4bd3-8b91-a6b1c4a3fa65.png)

![가계부 작성2](https://user-images.githubusercontent.com/60167644/127848267-21ec2d1b-f148-4c35-b90c-0ec497e88aab.png)

![일기 미리보기](https://user-images.githubusercontent.com/60167644/127848276-e5110b71-7ed6-44eb-a613-2dd14966d9bf.png)

![일기상세보기](https://user-images.githubusercontent.com/60167644/127848288-57118c84-a724-4fbe-9abd-5854ea805611.png)

## 클라이언트 구조

1. 메인 페이지

2. 회원가입 (users 데이터베이스에 추가)

3. 로그인 된 페이지(일정페이지)

4. 일정 작성(할것) (일정 작성 페이지) → 일정 확인 페이지

5. 일기장 작성(한것) (일기 페이지)

    1. 일기 작성페이지

    2. 가계부 작성페이지

    3. 일기 확인 페이지

## 데이터 베이스 구조

일정

db_memo : user_id, date, text, createdAt

일기장

db_diary : user_id, date, diary(Object), money(Array)  
diary(Object) : title, file_id, text, createdAt  
money(Array) : time, money, option, text

## 일정 작성 구조

📝memo_writing.js

```js
FlowRouter.template('/memo_writing/:_id','memo_writing');

Template.memo_writing.onRendered(function () {
    $('#editor').summernote({
        toolbar: [
            ['Font Style',['fontsize','color']],
            ['Paragraph style',['ul']]
        ],
        lang: 'ko-KR',
        minHeight: 110,
        maximumImageFileSize: 1048576*10
    });
    $('#editor').summernote('insertUnorderedList');
});

Template.memo_writing.onDestroyed(function () {

});

Template.memo_writing.helpers({
    memo: function () {
        var _id = FlowRouter.getParam('_id');
        if(_id === 'newPosting') {
            return {};    //새글 작성일때는 화면에 비어있는 데이터를 제공.
        }

       Meteor.setTimeout(function() { //화면 에디터에 편집 모드를 초기화 하기 위한 트릭
            $('#editor').summernote('reset')
        });

        return DB_MEMO.findOne({_id:_id});
    }
})


Template.memo_writing.events({
    'click #btn-head-write': function () {
        var user_id =  Meteor.user()._id;
        var date = $('#inp-day').val();
        var text = $('#editor').summernote('code');
        if (!date) {
            return alert('날짜를 반드시 입력 해 주세요.');
        }
        var _id = FlowRouter.getParam('_id');
        if( _id === 'newPosting') {
            var date_option = DB_MEMO.findOne({user_id: user_id,date:date});
            if(date_option)
            {
                return alert('같은 날짜로된 일정이 이미 존재합니다.');
            }
            DB_MEMO.insert({
                user_id: user_id,
                date: date,
                text: text,
                createdAt: new Date(),
            })
        } else {
            var memo = DB_MEMO.findOne({_id:_id});
            if(memo.date != date)
            {
                alert('수정 불가능한 날짜의 메모입니다.');
                date = memo.date;
                memo.text = text;
                DB_MEMO.update({_id:_id}, memo);
                return history.go(0);
            }
            memo.date = date;
            memo.text = text;
            memo.createdAt = new Date();
            DB_MEMO.update({_id:_id}, memo);
        }

        alert('일정을 저장하였습니다.');
        $('#inp-day').val('');
        $('#editor').summernote('reset');
        FlowRouter.go('/memo');
    }
})
```

1. key = user_id로 개인별 데이터 구성

2. 주소의 \_id가 newPosting 이면 새 일정 작성

   1. 변수 date_option로 같은 날짜의 일정이 존재하면 작성 안됨

3. 주소의 \_id가 이미 작성된 일정의 \_id 이면 해당 일정 수정

   1. 수정 하고자 하는 일정과 같은 날짜의 일정만 수정 가능

## 일기 작성 구조

📝diary_writing.js

```js
FlowRouter.template('/diary_writing/:_id','diary_writing');

Template.diary_writing.onRendered(function () {
    $('#editor').summernote({
        toolbar: [
            ['Font Style',['fontsize','color']],
            ['insert',['picture','link','video']]
        ],
        lang: 'ko-KR',
        minHeight: 110,
        maximumImageFileSize: 1048576*10
    });
});

Template.diary_writing.onDestroyed(function () {

});


Template.diary_writing.helpers({
    diarys: function () {
        var _id = FlowRouter.getParam('_id');
        if(_id === 'newPosting') {
            return {};    //새글 작성일때는 화면에 비어있는 데이터를 제공.
        }
        Meteor.setTimeout(function() { //화면 에디터에 편집 모드를 초기화 하기 위한 트릭
            $('#editor').summernote('reset');
        });
        return DB_DIARY.findOne({_id:_id});
    },
    file: function() {
        return DB_FILES.findOne({_id: this.diary.file_id}).name;
    }
})

Template.diary_writing.events({
    'click #btn-diary-write':function () {
        var user_id = Meteor.user()._id;
        var date = $('#inp-day').val();
        var title = $('#inp-name').val();
        if(!$('#inp-music').prop('files')[0]){
            return alert('mp3파일을 선택해주세요.')
        }
        var file = $('#inp-music').prop('files')[0];
        var file_id = DB_FILES.insertFile(file);
        var text = $('#editor').summernote('code');
        if(!title){
            return alert('제목을 작성해주세요.');
        }
        if(!date){
            return alert('날짜를 작성해주세요.');
        }
        var _id = FlowRouter.getParam('_id');
        if( _id === 'newPosting'){
            var date_option = DB_DIARY.findOne({user_id: user_id,date:date});
            if(date_option)
            {
                return alert('같은 날짜로된 일정이 이미 존재합니다.');
            }
            DB_DIARY.insert({
                user_id: user_id,
                date: date,
                diary:{
                    title: title,
                    file_id: file_id,
                    text: text,
                    createdAt: new Date()
                }
            })
        }
        else{
            var diary = DB_DIARY.findOne({_id:_id});
            if(diary.date != date)
            {
                alert('수정 불가능한 날짜의 일정입니다.');
                date = diary.date;
                diary.diary.title = title;
                diary.diary.text = text;
                DB_DIARY.update({_id:_id}, diary);
                return history.go(0);
            }
            diary.diary.title= title;
            diary.diary.file_id = file_id;
            diary.diary.text = text
            diary.diary.createdAt = new Date();
            DB_DIARY.update({_id:_id}, diary);
        }
        alert('일기를 작성하였습니다.');
        $('#inp-day').val('');
        $('#inp-music').val('');
        $('#editor').summernote('reset');
        FlowRouter.go('/diary');
    }
})
```

1. key = user_id로 개인별 데이터 구성

2. 주소의 \_id가 newPosting 이면 새 일기 작성

   1. 변수 date_option로 같은 날짜의 일기가 존재하면 작성 안됨

3. 주소의 \_id가 이미 작성된 일기의 \_id 이면 해당 일기 수정

   1. 수정 하고자 하는 일기와 같은 날짜의 일기만 수정 가능

## 가계부 작성 구조

📝money_writing.js

```js
FlowRouter.template('/money_writing','money_writing');

Template.money_writing.onRendered(function () {

});

Template.money_writing.onDestroyed(function () {

});

Template.money_writing.events({
    'click #btn-money-save':function() {
        var user_id = Meteor.user()._id;
        var date = $('#inp-day').val();
        var time = $('#inp-time').val();
        var money = $('#inp-money').val();
        var option = $('#select-money').val();
        var text = $('#inp-money-text').val();
        var date_option = DB_DIARY.findOne({user_id: user_id,date:date});
        if(date_option)
        {
            DB_DIARY.update({_id:date_option._id},{
                $push:{
                    money:{
                        time: time,
                        money: money,
                        option: option,
                        text: text,
                    }
                }
            })
        }
        else{
            DB_DIARY.insert({
                date: date,
                user_id: user_id,
                diary:{},
                money:[{
                    time: time,
                    money: money,
                    option: option,
                    text: text,
                }]
            });
        }
        alert('가계부를 작성하였습니다.');
        FlowRouter.go('/diary');
    }
})
```

1. key = user_id로 개인별 데이터 구성

2. date_option변수로 해당 날짜에 일기가 존재한다면 가계부 업데이트

3. 해당 날짜에 일기가 존재하지 않는다면 DB 생성후 가계부 설정

## 아쉬운점

일기 작성에서 파일 저장 구조  
가계부에서 금액 수정이나 삭제 기능 구현하지 못함
