export class Poller {
    interval: number;
    callbackFunction: () => any | Promise<any>;
    timeOut: null | ReturnType<typeof setTimeout> = null;
    isImmediate!: boolean;
    pausedAtTimestamp = 0;
    nextPollTimestamp = 0;
    _isStopped = false;

    constructor(interval: number, callbackFunction: () => any | Promise<any>) {
        this.interval = interval;
        this.callbackFunction = callbackFunction;
    }

    //////////////////////////
    // UTIL METHODS/WRAPPERS
    //////////////////////////

    /**
     * @dev Calls the callback, awaits its result, then updates `nextPollTimestamp`
     * @notice This function is internal and **MUST NOT** be called externally
     */
    async _callbackFunctionTimestamped() {
        await this.callbackFunction();
        this.nextPollTimestamp = Date.now() + this.interval;
    }

    /**
     * @dev Custom implementaion of setInterval that fires async callbacks only when previous one is completed (AFTER WAITING FOR `intervalMs`)
     * @notice This function is internal and **MUST NOT** be called externally
     * @param callback Callback to call after every `intervalMs` (after previous callback invocation completes)
     * @param intervalMs Interval duration to wait for, in milliseconds
     * @param args Args to pass into `callback`.
     */
    _setInterval(callback: () => any | Promise<any>, intervalMs: number, ...args: Array<any>) {
        if (this._isStopped) return;
        this.timeOut = setTimeout(async () => {
            await callback();

            this._setInterval(callback, intervalMs, args);
        }, intervalMs, args) as unknown as ReturnType<typeof setTimeout>;
    }

    //////////////////////////
    // POLLER METHODS
    //////////////////////////

    /**
     * @dev Called when Polling should start
     * @notice This attaches event listeners for window active/inactive event
     * @param isImmediate Should polling start immediately
     */
    async start(isImmediate = false) {
        this.isImmediate = isImmediate; // Saved for `resume()`

        if (isImmediate) {
            await this._callbackFunctionTimestamped();
        }

        this._setInterval(this._callbackFunctionTimestamped.bind(this), this.interval);
    }

    /**
     * @dev Called internally when polling should resume after a window inactive event
     * @notice This function is internal and **MUST NOT** be called externally
     * @notice This function is the same as `start()` EXCEPT that it does not reattach new window listeners
     */
    async _resume() {
        // Calculate interval left to fire callback again
        const intervalToWait = this.nextPollTimestamp - Date.now();
        this.timeOut = setTimeout(async () => {
            // Execute callback after waiting for remaining interval
            await this._callbackFunctionTimestamped();

            // Then set polling again
            this._setInterval(this._callbackFunctionTimestamped.bind(this), this.interval);
        }, Math.max(intervalToWait, 0));
    }

    /**
     * @dev Stops polling and removes window active/inactive listeners
     * @notice This function is internal and **MUST NOT** be called externally
     * @notice This function is the same as `start()` EXCEPT that it does not remove window listeners
     */
    _pause() {
        this.pausedAtTimestamp = Date.now();
        this.timeOut && clearTimeout(this.timeOut);
    }

    /**
     * @dev Stops polling and removes window active/inactive listeners
     */
    stop() {
        this.timeOut && clearTimeout(this.timeOut);
        this._isStopped = true;
    }

    /**
     * @dev Restarts polling
     */
    restart() {
        this.stop();
        this.start(true);
    }
}