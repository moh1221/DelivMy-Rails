"use strict";

function renderDeliveryTimers(root = document) {
  root.querySelectorAll("time[data-delivery]").forEach((timer) => {
    const until = Date.parse(timer.dateTime);
    if (!Number.isFinite(until)) return;
    const minutes = Math.ceil((until - Date.now()) / 60000);
    if (minutes <= 0) {
      timer.textContent = "Expired";
      return;
    }
    const units = minutes >= 1440 ? [Math.floor(minutes / 1440), "day"] :
      minutes >= 60 ? [Math.floor(minutes / 60), "hour"] : [minutes, "minute"];
    timer.textContent = `within ${units[0]} ${units[1]}${units[0] === 1 ? "" : "s"}`;
  });
}

let itemIndex = Date.now();

document.addEventListener("click", (event) => {
  const add = event.target.closest("[data-add-item]");
  if (add) {
    const list = document.querySelector("#request-items");
    const template = document.querySelector("#request-item-template");
    const fragment = template.content.cloneNode(true);
    const index = String(++itemIndex);
    fragment.querySelectorAll("[name], [id], [for]").forEach((element) => {
      ["name", "id", "for"].forEach((attr) => {
        const value = element.getAttribute(attr);
        if (value) element.setAttribute(attr, value.replace("NEW_ITEM", index));
      });
    });
    list.append(fragment);
    list.lastElementChild.querySelector("input:not([type=hidden])")?.focus();
    return;
  }

  const remove = event.target.closest("[data-remove-item]");
  if (remove) {
    const row = remove.closest(".fields");
    row.querySelector('input[name$="[_destroy]"]').value = "1";
    row.hidden = true;
    document.querySelector("[data-add-item]")?.focus();
  }

  const toggle = event.target.closest("[data-menu-toggle]");
  if (toggle) {
    const menu = document.getElementById(toggle.getAttribute("aria-controls"));
    const expanded = menu.classList.toggle("show");
    toggle.setAttribute("aria-expanded", String(expanded));
  }
});

document.addEventListener("submit", (event) => {
  const confirmText = event.target.dataset.confirm;
  if (confirmText && !window.confirm(confirmText)) event.preventDefault();
});

document.addEventListener("DOMContentLoaded", () => {
  renderDeliveryTimers();
  setInterval(renderDeliveryTimers, 60000);

  const address = document.querySelector("#AddInfo");
  const lat = document.querySelector("#LatInfo");
  const lon = document.querySelector("#LongInfo");
  const locationButton = document.querySelector("[data-locate]");
  const locationStatus = document.querySelector("#location-status");
  if (locationButton && address && lat && lon && locationStatus) {
    locationButton.addEventListener("click", () => {
      if (!navigator.geolocation) {
        locationStatus.textContent = "Location is not available. Enter the coordinates manually.";
        return;
      }
      navigator.geolocation.getCurrentPosition(({ coords }) => {
        lat.value = coords.latitude;
        lon.value = coords.longitude;
        locationStatus.textContent = "Current coordinates added. Enter the pickup address.";
      }, () => {
        locationStatus.textContent = "Couldn't get your location. Enter the coordinates manually.";
      });
    });
    address.addEventListener("change", () => {
      if (!window.google?.maps?.Geocoder || !address.value.trim()) return;
      const value = address.value;
      new google.maps.Geocoder().geocode({ address: value }, (results, status) => {
        if (address.value !== value) return;
        if (status !== "OK" || !results[0]) {
          locationStatus.textContent = "Couldn't locate that address. Check or enter the coordinates manually.";
          return;
        }
        lat.value = results[0].geometry.location.lat();
        lon.value = results[0].geometry.location.lng();
        locationStatus.textContent = "Pickup coordinates updated.";
      });
    });
  }
});

let mapInitialized = false;
window.initializeDelivMap = function () {
  const container = document.querySelector("#delivery-map");
  if (!container || !window.google?.maps?.Map || mapInitialized) return;
  mapInitialized = true;
  container.hidden = false;
  const map = new google.maps.Map(container, {
    center: { lat: 37.7, lng: -97.3 },
    zoom: 4,
    streetViewControl: false,
  });
  const list = document.querySelector("#list");
  let pending;
  const info = new google.maps.InfoWindow();
  let markers = [];

  map.addListener("idle", async () => {
    const bounds = map.getBounds();
    if (!bounds) return;
    pending?.abort();
    pending = new AbortController();
    const controller = pending;
    const sw = bounds.getSouthWest();
    const ne = bounds.getNorthEast();
    const query = new URLSearchParams({
      sw: `${sw.lat()},${sw.lng()}`,
      ne: `${ne.lat()},${ne.lng()}`,
    });

    try {
      const [ordersResponse, listResponse] = await Promise.all([
        fetch(`/search.json?${query}`, { signal: controller.signal }),
        fetch(`/search?partial=1&${query}`, { signal: controller.signal }),
      ]);
      if (!ordersResponse.ok || !listResponse.ok || listResponse.redirected) return;
      const [orders, html] = await Promise.all([ordersResponse.json(), listResponse.text()]);
      if (controller.signal.aborted) return;
      list.innerHTML = html;
      renderDeliveryTimers(list);
      markers.forEach((marker) => marker.setMap(null));
      markers = orders.filter((order) => order.location).map((order) => {
        const marker = new google.maps.Marker({
          position: { lat: Number(order.location.Lat), lng: Number(order.location.Long) },
          title: order.PlaceName,
          map,
        });
        marker.addListener("click", () => {
          const content = document.createElement("a");
          content.textContent = `${order.PlaceName} · $${order.fees} tip`;
          content.href = `/search/${encodeURIComponent(order.id)}`;
          info.setContent(content);
          info.open({ anchor: marker, map });
        });
        return marker;
      });
    } catch (error) {
      if (error.name !== "AbortError") return;
    }
  });
};
