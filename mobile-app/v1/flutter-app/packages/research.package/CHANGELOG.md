## 0.5.5
- small update to robustness and debug info in `RPLocalizations`

## 0.5.4
- update to the localization model (`RPLocalizations`) so that:
   - the localization of the embedded text in RP is now part of RP (you don't need to worry about this anymore)
   - localization of informed consent and survey is (still) in the `assets/lang/` folder
   - support for custom [LocalizationLoader]s which can load translations from other sources
- another localization class has been added `AssetsLocalizations`, which can load translations from json files. This is useful for e.g. simple localization of static text in an app
- example app update to illustrate the use of both types of localization

## 0.5.3+1
- small updates to documentation
- making `RPTask` serializable instead of abtstract
- fix to `translate` method

## 0.5.2
- update of json serialization in informed consent domain model
- updated example and unit test on `RPConsentSection` for passive data collection

## 0.5.0

- Included the [carp_core](https://pub.dev/packages/carp_core) which allow for de/serialization of RP models to/from json, while also supporting polymorphim (e.g., that an `RPAnswerFormat` can have different implementations). See [issue #12](https://github.com/cph-cachet/research.package/issues/12).
- all `.withParams()` and similar constructors have been replaced with named constructors (as recommended in Dart).
- added unit test to verify json de/serialization.
- all examples and the demo app updated accordingly.

## 0.4.1

- Fixed error in consent that caused it to have 2 top bars
- Updated docs 
- Score fixes 

## 0.4.0

- Merged beta.1.0
- Added RPTextAnswerFormat (a format for getting written answers from the user)
- Minor bugfixes

## 0.4.0-beta.1.0

- Updated UI for several elements:
  - RPQuestionStep (incl. most answerformats)
  - RPFormStep
  - RPInstructionStep
  - RPVisualConsentStep
- Added new consent types:
  - User data collection
  - Passive data collection
- Added simple support for theming in Research Package
- Minor bug fixes

## 0.3.2+3

- updates to documentation of RP and example app

## 0.3.2+2

- Added RPJumpStepRule - A navigation rule to jump to questions based on the chosen answer to the question.

## 0.3.2+1

- Revert of AnimationController

## 0.3.2

- Updated `AnimationController`s to Flutter 1.22
- Removed "Activity Steps" to be released in a separate package
- Merged small-scale branching feature
- Minor bugfixes

## 0.3.1+1

- `onCancel` callback changed to only optional

## 0.3.1

- `onCancel` callback added to Tasks

## 0.3.0

- `RPActivityStep` and `RPActivityResult` added with including UI.
- 8 cognitive tests added as activity steps.
- Dependencies updated
- Minor bugfixes

## 0.2.1

- FormStep now supports Slider, Image, Date and Boolean Answer Formats as well

## 0.2.0

- Support for Navigable Tasks
  - Branching support with `RPDirectStepNavigationRule` and `RPPredicateStepNavigationRule`
  - Navigation to previous questions
  - Currently supports:
    - Boolean Answer Format
    - Choice Answer Format
- Localization added
  - Demo app available now in English and Danish
- Support for new Answer Format
  - Boolean
- UI updates, bug fixes

## 0.1.2

- Support for new Answer Formats
  - Slider
  - Date and Time
  - Image Choice
- `rx_dart` dependency updated to `^0.23.0`
- Small bug fixes and documentation update

## 0.1.1

- `json_annotation` dependency updated to `^3.0.0`
- `rx_dart` dependency updated to `^0.22.0`

## 0.1.0

- Form Step feature added
- Bug fixing

## 0.0.4

- Example application added

## 0.0.3

- Initial release for Pub
- Support for three Answer Formats
  - Single Choice
  - Multiple Choice
  - Integer

## 0.0.2

- Added initial support for serialization to/from JSON
- JSON serialization is available for these classes:
  - `RPAnswerFormat`
  - `RPChoiceAnswerFormat`
  - `RPIntegerAnswerFormat`
  - `RPConsentDocument`
  - `RPConsentSection`
  - `RPSignatureResult`
  - `RPStepResult`
  - `RPTaskResult`
  - `RPChoice`

## 0.0.1

- Initial release
- Entire framework done
- Support for SingleChoice question type
