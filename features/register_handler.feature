Feature: Register Handler

  Background:
    Given a file named "features/my_feature.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given a step
      """
    And a file named "features/step_definitions/my_steps.js" with:
      """
      stepDefinitions = function() {
        this.When(/^a step$/, function () {
          this.value = 1;
        });
      };

      module.exports = stepDefinitions
      """

  Scenario: synchronous
    Given a file named "features/support/hooks.js" with:
      """
      hooks = function() {
        this.registerHandler('AfterFeatures', function () {});
      };

      module.exports = hooks
      """
    When I run cucumber.js
    And the exit status should be 0

  Scenario: synchronously throws
    Given a file named "features/support/hooks.js" with:
      """
      hooks = function() {
        this.registerHandler('AfterFeatures', function(){
          throw new Error('my error');
        });
      };

      module.exports = hooks
      """
    When I run cucumber.js
    And the exit status should be non-zero

  Scenario: callback without error
    Given a file named "features/support/hooks.js" with:
      """
      assert = require('assert');

      hooks = function() {
        this.registerHandler('AfterFeatures', function(event, callback) {
          setTimeout(function () {
            callback();
          });
        });
      };

      module.exports = hooks
      """
    When I run cucumber.js
    And the exit status should be 0

  Scenario: callback with error
    Given a file named "features/support/hooks.js" with:
      """
      hooks = function() {
        this.registerHandler('AfterFeatures', function(event, callback) {
          setTimeout(function() {
            callback(new Error('my error'));
          });
        });
      };

      module.exports = hooks
      """
    When I run cucumber.js
    And the exit status should be non-zero

  Scenario: callback asynchronously throws
    Given a file named "features/support/hooks.js" with:
      """
      hooks = function() {
        this.registerHandler('AfterFeatures', function(event, callback){
          setTimeout(function(){
            throw new Error('my error');
          });
        });
      };

      module.exports = hooks
      """
    When I run cucumber.js
    And the exit status should be non-zero

  Scenario: callback - returning a promise
    Given a file named "features/step_definitions/failing_steps.js" with:
      """
      hooks = function() {
        this.registerHandler('AfterFeatures', function(event, callback){
          return {
            then: function() {}
          };
        });
      };

      module.exports = hooks
      """
    When I run cucumber.js
    And the exit status should be non-zero
    And the error output contains the text:
      """
      function accepts a callback and returns a promise
      """

  Scenario: promise resolves
    Given a file named "features/support/hooks.js" with:
      """
      hooks = function() {
        this.registerHandler('AfterFeatures', function() {
          return {
            then: function(resolve, reject) {
              setTimeout(resolve);
            }
          };
        });
      };

      module.exports = hooks
      """
    When I run cucumber.js
    And the exit status should be 0

  Scenario: promise rejects with error
    Given a file named "features/support/hooks.js" with:
      """
      hooks = function() {
        this.registerHandler('AfterFeatures', function() {
          return {
            then: function(resolve, reject) {
              setTimeout(function () {
                reject(new Error('my error'));
              });
            }
          };
        });
      };

      module.exports = hooks
      """
    When I run cucumber.js
    And the exit status should be non-zero

  Scenario: promise rejects without error
    Given a file named "features/support/hooks.js" with:
      """
      hooks = function() {
        this.registerHandler('AfterFeatures', function() {
          return {
            then: function(resolve, reject) {
              setTimeout(reject);
            }
          };
        });
      };

      module.exports = hooks
      """
    When I run cucumber.js
    And the exit status should be non-zero

  Scenario: promise asynchronously throws
    Given a file named "features/support/hooks.js" with:
      """
      hooks = function(){
        this.registerHandler('AfterFeatures', function() {
          return {
            then: function(resolve, reject) {
              setTimeout(function(){
                throw new Error('my error');
              });
            }
          };
        });
      };

      module.exports = hooks
      """
    When I run cucumber.js
    And the exit status should be non-zero
