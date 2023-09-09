## Notes on Psychtoolbox Experiment Template

### Synopsis
The code in this folder implements a simple two-interval forced-choice (2IFC) speed discrimination experiment.
Each trial displays two intervals, a *reference* speed interval and a *comparison* speed interval, in random order and the observer's task is to indicate which of the two intervals, the first (`f`) or the second (`j`), was faster.
The intervals each show a horizontally drifting circle whose speed is determined by the `delta_speed` parameter passed to the `trial` function.

### Description of Files
The experiment itself isn't very interesting. The primary purpose of this template is to demonstrate how MATLAB/Psychtoolbox experiments are typically structured in our lab.

#### main.m: 
This is the entry point into the program and the only function that is called directly from the command line. It essentially runs a block of trials. Typically this consists of 4 tasks
1. Setting up and initializing the display environment and the eye tracker (if available).
2. Setting up the trial sequence
3. Executing a loop that runs individual trials (via the `trial` function) until the block is complete
4. Saving the results of the block

#### trial.m:
This function runs a single experimental trial. Typically, this function includes one or more subfunctions that define repetitive subtasks (such as the drawing of cue markers). It typically takes one or more arguments defining parameters of the individual trial and returns the results of the trial (i.e., success or failure) along with other information (e.g., eye position, interval order, etc.).

#### exptParams.m:
This function sets up and returns a pair of structures (`display_parameters` and `stimulus_parameters`) that define the global parameters of the experiment. This (not the `main` or `trial` functions) is where you should indicate any parameters that are relevant to either the visual stimulus (e.g., size, spatial frequency, interstimulus interval duration, etc.) or to the physical set up of the display (e.g., screen size, subject distance, etc.).  

#### getResponse.m:
This function waits for and/or processes keypresses.

#### getEyelinkSample.m:
This function retrieves the most recent gaze position sample from the Eyelink tracker.

#### simple_main.m:
This function is superfluous and would not exist in a typical experiment. It implements a stripped-down, bare-bones main function that only displays a single frame then exits. It is just here as a minimal example of the code needed to display anything at all using the Psychtoolbox framework. 
 

