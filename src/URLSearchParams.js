export function get(paramName) {
  return function() {
    var url = new URL(window.location.toString());
    return url.searchParams.get(paramName);
  };
};
