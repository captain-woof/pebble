import { createApp } from 'vue';
import App from './App.vue';
import router from './plugins/router';
import vuetify from './plugins/vuetify';
import walletConnect from './plugins/wallet-connect';
import pinia from './plugins/pinia';

createApp(App)
    .use(router)
    .use(pinia)
    .use(vuetify)
    .use(walletConnect)
    .mount('#app');
