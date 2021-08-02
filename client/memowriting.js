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
                alert('수정 불가능한 날짜의 일정입니다.');
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




