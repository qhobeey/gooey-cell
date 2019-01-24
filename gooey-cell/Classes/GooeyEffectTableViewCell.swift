//
//  GooeyEffectTableViewCell.swift
//  gooey-cell
//
//  Created by Прегер Глеб on 22/01/2019.
//  Copyright © 2019 Cuberto. All rights reserved.
//

import UIKit

public protocol GooeyEffectTableViewCellDelegate: class {
    func gooeyEffectAction(for tableViewCell: UITableViewCell, direction: GooeyEffect.Direction)
    func gooeyEffectConfig(for tableViewCell: UITableViewCell, direction: GooeyEffect.Direction) -> GooeyEffect.Config?
}

open class GooeyEffectTableViewCell: UITableViewCell {
        
    private var effect: GooeyEffect?
    private var gesture: UIPanGestureRecognizer!
    
    open weak var gooeyEffectTableViewCellDelegate: GooeyEffectTableViewCellDelegate?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addGesture()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addGesture()
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        effect = nil
        gesture.isEnabled = true
    }
    
    private func addGesture() {
        gesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized))
        gesture.delegate = self
        contentView.addGestureRecognizer(gesture)
    }
    
    @objc private func panGestureRecognized(_ gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            
            let direction: GooeyEffect.Direction = gesture.velocity(in: contentView).x > 0 ? .toRight : .toLeft

            guard self.effect == nil,
                let config = gooeyEffectTableViewCellDelegate?.gooeyEffectConfig(for: self, direction: direction) else {
                    
                gesture.isEnabled = false
                gesture.isEnabled = true
                return
            }
            
            let verticalPosition = Float(gesture.location(in: contentView).y / contentView.bounds.height)
            
            effect = GooeyEffect(to: contentView,
                                 verticalPosition: verticalPosition,
                                 direction: direction,
                                 config: config)
            
        case .changed:
            
            guard let effect = effect else { return }
            
            var progress = Float(gesture.translation(in: contentView).x / effect.effectMaxWidth)
            
            if progress < 0 && effect.direction == .toRight ||
                progress > 0 && effect.direction == .toLeft {
                
                progress = 0
            } else {
                progress = abs(progress)
            }
            
            let nonlinearProgressLength: Float = 0.15
            let nonlinearProgressStart: Float = effect.gapProgressValue - nonlinearProgressLength

            let effectProgress: Float
            
            if progress > nonlinearProgressStart {
                
                let localProgress = (progress - (nonlinearProgressStart)) / nonlinearProgressLength
                let rate = Float(log10(Double(1 + localProgress)))
                
                if rate > 1 {
                    effectProgress = effect.gapProgressValue
                } else {
                    effectProgress = nonlinearProgressStart + nonlinearProgressLength * rate
                }
                
            } else {
                effectProgress = progress
            }
        
            effect.updateProgress(progress: effectProgress)

        case .cancelled, .ended, .failed:
            
            guard let effect = effect else { return }
          
            gesture.isEnabled = false

            let progress = abs(Float(gesture.translation(in: contentView).x / effect.effectMaxWidth))
            let finalEffectProgress: Float = progress < effect.gapProgressValue ? 0 : 1
            
            effect.animateToProgress(finalEffectProgress) { [weak self] in
                guard let self = self else { return }
                
                if finalEffectProgress == 1 {
                    self.gooeyEffectTableViewCellDelegate?.gooeyEffectAction(for: self, direction: effect.direction)
                } else {
                    self.effect = nil
                }
                
                gesture.isEnabled = true
            }
            
        case .possible:
            break
        }
    }
    
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == gesture,
            abs(gesture.translation(in: contentView).y) > 0 {
            return false
        }
        return true
    }
}
