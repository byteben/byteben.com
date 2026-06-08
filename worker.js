const REDIRECTS = [
  // Tags
  [/^\/bb\/tag\/(.+)/, (m) => `/tags/${m[1]}`],
  // Categories - subcategory paths (specific before generic)
  [/^\/(?:bb\/category|categories)\/microsoft\/windows-10(\/?)$/, () => `/categories/windows-10/`],
  [/^\/(?:bb\/category|categories)\/microsoft\/intune(\/?)$/, () => `/categories/intune/`],
  [/^\/(?:bb\/category|categories)\/microsoft\/azure(\/?)$/, () => `/categories/azure/`],
  [/^\/(?:bb\/category|categories)\/microsoft\/identity(\/?)$/, () => `/categories/identity/`],
  [/^\/(?:bb\/category|categories)\/microsoft\/onedrive(\/?)$/, () => `/categories/onedrive/`],
  [/^\/(?:bb\/category|categories)\/microsoft\/certificates(\/?)$/, () => `/categories/certificates/`],
  [/^\/(?:bb\/category|categories)\/microsoft\/office365(\/?)$/, () => `/categories/office365/`],
  [/^\/(?:bb\/category|categories)\/microsoft\/microsoft-exchange(\/?)$/, () => `/categories/microsoft-exchange/`],
  [/^\/(?:bb\/category|categories)\/microsoft\/configmgr-memcm-sccm(\/?)$/, () => `/categories/configmgr-memcm-sccm/`],
  [/^\/(?:bb\/category|categories)\/appsense\/appsense-desktopnow\/appsense-environmentmanager\/appsense-environmentmanager-configurations(\/?)$/, () => `/categories/appsense-environmentmanager-configurations/`],
  [/^\/(?:bb\/category|categories)\/appsense\/appsense-desktopnow\/appsense-environmentmanager\/appsense-environmentmanager-scripts(\/?)$/, () => `/categories/appsense-environmentmanager-scripts/`],
  [/^\/(?:bb\/category|categories)\/appsense\/appsense-desktopnow\/appsense-environmentmanager(\/?)$/, () => `/categories/appsense-environmentmanager/`],
  [/^\/(?:bb\/category|categories)\/appsense\/appsense-desktopnow\/appsense-managementcentre(\/?)$/, () => `/categories/appsense-managementcentre/`],
  [/^\/(?:bb\/category|categories)\/appsense\/appsense-desktopnow(\/?)$/, () => `/categories/appsense-desktopnow/`],
  [/^\/(?:bb\/category|categories)\/mitel\/mitel-3300(\/?)$/, () => `/categories/mitel-3300/`],
  [/^\/(?:bb\/category|categories)\/mitel\/mitel-contactcentre-pfyre(\/?)$/, () => `/categories/mitel-contactcentre-pfyre/`],
  [/^\/(?:bb\/category|categories)\/barracuda\/barracuda-loadbalancer340(\/?)$/, () => `/categories/barracuda-loadbalancer340/`],
  [/^\/(?:bb\/category|categories)\/cisco\/cisco-commandline(\/?)$/, () => `/categories/cisco-commandline/`],
  [/^\/(?:bb\/category|categories)\/landesk\/landesk-managmentsuite(\/?)$/, () => `/categories/landesk-managmentsuite/`],
  // Generic /bb/category/* -> /categories/*
  [/^\/bb\/category\/(.+)/, (m) => `/categories/${m[1]}`],
  // Author and page archives
  [/^\/bb\/author\//, () => `/`],
  [/^\/bb\/page\//, () => `/`],
  // Bare /bb
  [/^\/bb\/?$/, () => `/`],
];

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const path = url.pathname;

    for (const [pattern, target] of REDIRECTS) {
      const match = path.match(pattern);
      if (match) {
        const location = target(match);
        return Response.redirect(new URL(location, url).href, 301);
      }
    }

    return env.ASSETS.fetch(request);
  },
};
