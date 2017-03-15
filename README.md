# Memory Map iOS Game

Memory Map is an iOS version of an image-based version of the traditional game of Mahjong Tiles.

Images are fetched from Flickr's public API.

##### Default values:
 - Image Count = 9
 - Review Time = 15 seconds

##### Scores Captured:
 - Total Elapsed Time
 - Guess Accuracy %

##### Dependencies (Cocoapods):
 - Kingfisher - Image Download/Cache

##### Notes:

MVVM Design pattern used. Completely done on a single UIViewController. Optimallythe views such as ScoreView, InstructionView, and LoadingView should be created as separate custom UIViews, but have been implemented in the same UIViewController just to save time for now.

TODO :  Add Unit tests.

Please refer to the comments for further help.

Reach out to mohonish.c@gmail.com for feedback/questions/support.
