//
//  ViewController.swift
//  Drawing App
//
//  Created by Олег Ефимов on 29.11.2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    
    @IBOutlet weak var canvasView: CanvasView!
    
    private var colors: [UIColor] = [.black, .link, .red, .yellow, .green, .purple, .systemPink, .brown, .cyan, .magenta, .orange]
    
    private var selectedColorIdx: Int = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorsCollectionView.delegate = self
        colorsCollectionView.dataSource = self
    }

    @IBAction func didTapSaveButton(_ sender: UIButton) {
        let image = canvasView.takeScreenshot()
        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       #selector(onSaveImage(_:didFinishWithError:contextType:)),
                                       nil)
    }
    
    
    @IBAction func didTapUndoButton(_ sender: UIButton) {
        canvasView.undoDrawing()
    }
    
    
    @IBAction func didTapEraserButton(_ sender: UIButton) {
        canvasView.clearCanvas()
    }
    
    
    @IBAction func didChangeLineThickness(_ sender: UISlider) {
        canvasView.strokeWidth = CGFloat(sender.value) * 10
    }
    
    @IBAction func didChangeLineOpacity(_ sender: UISlider) {
        canvasView.strokeOpacity = CGFloat(sender.value)
    }
    
    @objc private func onSaveImage(_ image: UIImage, didFinishWithError error: Error?, contextType: UnsafeRawPointer) {
        if error != nil {
            showAlert(with: "Error", and: "Couldn't save image into gallery")
        } else {
            showAlert(with: "Success", and: "Image saved to gallery")
        }
    }
    
    private func showAlert(with title: String, and text: String?) {
        let alert = UIAlertController(title: title,
                                      message: text,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = colorsCollectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                                            for: indexPath)
        cell.backgroundColor = colors[indexPath.row]
        cell.layer.cornerRadius = 5
        if selectedColorIdx == indexPath.row {
            cell.layer.borderWidth = 2
            cell.layer.borderColor = UIColor.gray.cgColor
        } else {
            cell.layer.borderWidth = 0
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        colorsCollectionView.deselectItem(at: indexPath, animated: true)
        canvasView.strokeColor = colors[indexPath.row]
        let prevIndexPath = IndexPath(row: selectedColorIdx, section: indexPath.section)
        selectedColorIdx = indexPath.row
        DispatchQueue.main.async {
            self.colorsCollectionView.reloadItems(at: [prevIndexPath, indexPath])
        }
    }
}
