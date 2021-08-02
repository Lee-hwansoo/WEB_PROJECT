FlowRouter.template('/memo','memo');

Template.memo.onRendered(function () {
    $('html').css('height', '100%');
    $('body').css('height', '100%');
    $('#__blaze-root').css('height', '100%');
});

Template.memo.onDestroyed(function() {
    // 화면 이동 시 스크린 사이즈 전체를 활용을 해제 하기 위한 설정
    $('html').css('height', '');
    $('body').css('height', '');
    $('#__blaze-root').css('height', '');
});

Template.memo.helpers({
    memos: function() {
        var userInfo = Meteor.user();
        if(userInfo){
            var user_id = Meteor.user()._id;
            return DB_MEMO.findAll({user_id},{sort: {date: 1}});
        }
    },
    YMDHMS: function() {
        return this.createdAt.toStringYMDHMS();
    }
});

Template.memo.events({
    'click #btn-remove': function() {
        if(confirm('삭제 하시겠습니까?')) {
            DB_MEMO.remove({_id: this._id});
            alert('삭제 되었습니다.');
        }
    },
    'click #diary_writing':function () {

    }
});

Template.login_navbar.events({
    'click #logout': function () {
        Meteor.logout();
        FlowRouter.go('/');
        alert('로그아웃 되었습니다.');
    }
});