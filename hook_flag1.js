Java.perform(function() {
    var FlagOneActivity = Java.use("b3nac.injuredandroid.FlagOneActivity");
    FlagOneActivity.submitFlag.implementation = function(input) {
        console.log("[*] Input received by submitFlag: " + input);
    
        return this.submitFlag("the_real_flag"); 
    };
});
