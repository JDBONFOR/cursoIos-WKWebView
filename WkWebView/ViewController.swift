//
//  ViewController.swift
//  WkWebView
//
//  Created by Juan Bonforti on 06/06/2020.
//  Copyright © 2020 Juan Bonforti. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    // MARK: IBOutlet
    @IBOutlet weak var backButtom: UIBarButtonItem!
    @IBOutlet weak var fowardButton: UIBarButtonItem!
    
    // MARK: Private
    private let searchBar = UISearchBar()
    private var webView = WKWebView()
    private let refreshControl = UIRefreshControl() // Componente que se puede agregar a las vistas con Scroll.
    private let baseUrl = "https://www.google.com"
    private let searchPath = "/search?q="
    
    // MARK: ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation Buttons
        backButtom.isEnabled = false
        fowardButton.isEnabled = false
        
        // Search bar
        self.navigationItem.titleView = searchBar // Añado a la seccion del navigation indicada como title, mi barra de busqueda
        searchBar.delegate = self // implementacion el delegado a la SearchBar. Le indico que es nuestro viewController
        
        // WebView
        let webViewPrefs = WKPreferences()
        webViewPrefs.javaScriptEnabled = true; // Habilitamos JS
        webViewPrefs.javaScriptCanOpenWindowsAutomatically = true // Habilitamos que se pueden abrir windows por JavaScript.
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.preferences = webViewPrefs
        webView = WKWebView(frame: view.frame, configuration: webViewConfiguration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // Le indicamos que genere el ancho/alto flexible.
        webView.scrollView.keyboardDismissMode = .onDrag // Cuando el webView detecta q hacemos scroll, oculta el teclado.
        view.addSubview(webView)
        webView.navigationDelegate = self; // Aplico delegado al WebView para controlar al refreshControl
        
        
        // Refresh Control
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged) // Le indicamos acciones al refreshControl, el targes es el propio viewController, con @objc la action es la funcion creada y como finalidad en for: le indicamos valueChanged
        webView.scrollView.addSubview(refreshControl) // A la vista scroll del webView se le agrega el control de refresco
        view.bringSubviewToFront(refreshControl) // Traemos al frente el refresh control.
        
        loadUrl(url: baseUrl)
    }
    
    // MARK: IBAction
    @IBAction func backButtonAction(_ sender: Any) {
        webView.goBack()
    }
    
    @IBAction func fowardButtonAction(_ sender: Any) {
        webView.goForward()
    }
    
    // MARK: Private methods
    private func loadUrl( url: String){
        
        // Revisemos que sea una URL
        var urlToLoad:URL!
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            urlToLoad = url
        } else {
            let urlEncoding:String = url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            urlToLoad = URL(string: "\(baseUrl)\(searchPath)\(urlEncoding)")!
        }
        
        webView.load( URLRequest(url: urlToLoad!) )
    }
    @objc private func reload() {
        webView.reload()
    }
    
}

// MARK: - UISearchBarDelegate.
extension ViewController: UISearchBarDelegate {
    
    // Oculto el teclado, al dar click en buscar.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        loadUrl(url: searchBar.text ?? "")
    }
}
// MARK: - WKNavigationDelegate.
extension ViewController: WKNavigationDelegate {
    // Operacion de cuando termino.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        refreshControl.endRefreshing()
        backButtom.isEnabled = webView.canGoBack
        fowardButton.isEnabled = webView.canGoForward
    }
    // Operacion que es cuando comienza la navegacion.
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        refreshControl.beginRefreshing()
        
        // Escribir la pagina en la que estamos accediendo
        searchBar.text = webView.url?.absoluteString
    }
}

