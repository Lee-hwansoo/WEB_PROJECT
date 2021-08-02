FlowRouter.template('/diary','diary');

Template.diary.onRendered(function () {
    $('html').css('height', '100%');
    $('body').css('height', '100%');
    $('#__blaze-root').css('height', '100%');
});

Template.diary.onDestroyed(function () {
    $('html').css('height', '');
    $('body').css('height', '');
    $('#__blaze-root').css('height', '');
});
Template.diary.helpers({
    diarys: function () {
        var userInfo = Meteor.user();
        if (userInfo) {
            var user_id = Meteor.user()._id;
            return DB_DIARY.findAll({user_id: user_id}, {sort: {date: -1}});
        }

    },
    link: function() {
       return DB_FILES.findOne({_id: this.diary.file_id}).link();
    },
    income: function() {
        var total = 0;
        this.money.forEach(function(item) {
            if(item.option == '수입'){
                total = parseInt(total) + parseInt(item.money);
            }
        })
        return total;
    },
    outcome: function () {
        var total = 0;
        this.money.forEach(function (item) {
            if(item.option == '지출'){
                total = parseInt(total) + parseInt(item.money);
            }
        })
        return total;
    }
})


Template.diary.events({

});