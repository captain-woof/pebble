import { defineStore } from "pinia";

export interface ToastStoreState {
    toastMessage: null | string;
}

const useToastStore = defineStore("toast", {
    state: (): ToastStoreState => ({
        toastMessage: null
    }),
    actions: {
        showToast(message: string, durationInSecs: number = 3) {
            this.toastMessage = message;
            setTimeout(() => {
                this.toastMessage = null;
            }, durationInSecs * 1000);
        }
    }
});

export default useToastStore;