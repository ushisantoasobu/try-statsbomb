//
//  CheckPositionViewController.swift
//  try-statsbomb
//
//  Created by Shunsuke Sato on 2022/08/05.
//

import UIKit

class CheckPositionViewController: UIViewController {

    var fieldView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        drawField()

        for i in 1...25 {
            let pos = PositionToViewConverter().convert(positionId: i)
            let view = BasicPlayerView(
                frame: .init(
                    x: fieldView.frame.width * pos.x,
                    y: fieldView.frame.height * (1 - pos.y),
                    width: 10,
                    height: 10
                )
            )
            fieldView.addSubview(view)
        }
    }

    func drawField() {
        let viewFrame = view.frame
        let viewRatio = viewFrame.size.height / viewFrame.size.width

        if Field.fieldRatio > viewRatio {
            let verticalMarginRatio: CGFloat = 0.1
            let height = viewFrame.size.height * (1 - verticalMarginRatio * 2)
            let width = height / Field.fieldRatio
            fieldView = .init(
                frame: .init(
                    x: (view.frame.size.width - width) / 2,
                    y: (view.frame.size.height - height) / 2,
                    width: width,
                    height: height
                )
            )
        } else {
            let horizontalMarginRatio: CGFloat = 0.1
            let width = viewFrame.size.width * (1 - horizontalMarginRatio * 2)
            let height = width * Field.fieldRatio
            fieldView = .init(
                frame: .init(
                    x: (view.frame.size.width - width) / 2,
                    y: (view.frame.size.height - height) / 2,
                    width: width,
                    height: height
                )
            )
        }

        fieldView.backgroundColor = .lightGray
        view.addSubview(fieldView)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
