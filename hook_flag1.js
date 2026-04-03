Java.perform(function() {
    var FlagOneActivity = Java.use("b3nac.injuredandroid.FlagOneActivity");
    FlagOneActivity.submitFlag.implementation = function(input) {
        console.log("[*] Input received by submitFlag: " + input);
        // Contourner la vérification en retournant une valeur de drapeau correcte
        // Remplacez 'the_real_flag' par le flag réel si vous le connaissez, ou par une valeur qui permet de passer la vérification.
        return this.submitFlag("the_real_flag"); 
    };
});
