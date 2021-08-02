FlowRouter.template('/diary_view/:_id','diary_view');


Template.diary_view.onRendered(function () {

});

Template.diary_view.onDestroyed(function () {

});

Template.diary_view.helpers({
    diarys: function() {
        var _id = FlowRouter.getParam('_id')
        return DB_DIARY.findOne({_id: _id});
    },
    createdAt: function() {
        return this.diary.createdAt.toStringYMDHMS();
    },
    link: function() {
        return DB_FILES.findOne({_id: this.diary.file_id}).link();
    },
    money_detail: function () {
        return this.money;
    }
})


Template.diary_view.events({
    'click #btn-remove': function() {
        if(confirm('일기를 삭제 하시겠습니까?')) {
            var _id = FlowRouter.getParam('_id')
            DB_DIARY.remove({_id: _id});
            alert('삭제 되었습니다.');
            FlowRouter.go('/diary');
        }
    }
})
